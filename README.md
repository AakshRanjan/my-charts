# my-charts

Helm-based installs and Kubernetes manifests for a homelab cluster: ingress, storage, observability, Cloudflare Tunnel, and a few apps.

## Prerequisites

- Kubernetes cluster with `kubectl` configured
- [Helm](https://helm.sh/) 3.x
- Cluster admin rights to install CRDs and cluster-scoped resources (where charts require it)

## Layout

| Path | Purpose |
|------|---------|
| `infra/` | Cluster infrastructure (ingress, storage, metrics, monitoring, TLS, tunnel) |
| `apps/` | Applications (Jenkins, examples) |

Each subfolder with an `install.sh` is intended to be run from your machine with `kubectl` pointed at the right context.

## Suggested install order

1. **ingress-nginx** — HTTP(S) ingress controller for `Ingress` resources.
2. **cert-manager** — TLS certificates (if you use ACME / cert-manager issuers).
3. **longhorn** — Block storage + optional UI ingress + `longhorn-2` StorageClass (two replicas).
4. **metrics-server** — Resource metrics API (`kubectl top`, HPA). Install **kube-prometheus-stack** first if you use the bundled `ServiceMonitor` (needs Prometheus Operator CRDs).
5. **kube-prometheus-stack** — Prometheus, Alertmanager, Grafana (defaults + `values.yaml` for Grafana `root_url`).
6. **cloudflare-tunnel** — `cloudflared` Deployment; **create the tunnel token Secret out of band** (not in Git). See [Tunnel](#cloudflare-tunnel) below.
7. **apps** — e.g. Jenkins, example httpbin, as needed.

## Infrastructure

### ingress-nginx

```bash
bash infra/ingress-nginx/install.sh
```

Uses `infra/ingress-nginx/values.yaml` to allow snippet annotations (needed for some apps behind Cloudflare Tunnel on HTTP→nginx).

### cert-manager

```bash
bash infra/cert-manager/install.sh
```

### Longhorn

```bash
bash infra/longhorn/install.sh
```

Installs Longhorn, applies `longhorn-ingress.yaml`, and `storageclass-2-replicas.yaml` (`longhorn-2`). Use **`longhorn-2`** when only two nodes schedule Longhorn storage (avoids three-replica volumes that never become healthy).

### metrics-server

```bash
bash infra/metrics-server/install.sh
```

`values.yaml` enables Prometheus `ServiceMonitor` scraping (requires Prometheus Operator / kube-prometheus-stack CRDs).

### kube-prometheus-stack

```bash
bash infra/kube-prometheus-stack/install.sh
```

Applies `grafana-ingress.yaml` after Helm. Grafana `root_url` is set in `values.yaml` for use behind a reverse proxy / public hostname.

### Cloudflare tunnel

```bash
bash infra/cloudflare-tunnel/install.sh
```

- Mounts `configmap.yaml` for `cloudflared` ingress rules.
- **Do not commit** `TUNNEL_TOKEN`; the Deployment expects Secret `cloudflare-tunnel` / key `tunnelToken`.

**Important:**

- With **`TUNNEL_TOKEN`**, the [Zero Trust dashboard](https://one.dash.cloudflare.com/) may **push** tunnel routes and **override** the ConfigMap. Align **public hostname** routes in the UI with this repo, or rely on the dashboard as source of truth.
- For **HTTPS** `service` URLs to `ingress-nginx-controller` on **:443**, you usually need **No TLS Verify** (or `originRequest.noTLSVerify: true` in YAML) because nginx uses the **default ingress certificate** (not a public CA).
- Published routes **path** must match your app (e.g. do **not** use `^/blog` for Jenkins at `/`).
- Jenkins-specific notes: **HTTP** to nginx **:80** plus nginx `configuration-snippet` headers in `apps/jenkins/values.yaml` is supported; **HTTPS** to **:443** with **No TLS Verify** is an alternative.

## Apps

### Jenkins

```bash
bash apps/jenkins/install.sh
```

- Chart: `jenkins/jenkins` Helm chart; `values.yaml` holds `persistence`, `ingress`, `jenkinsUrl`, `JCasC`, etc.
- Existing PVC **storageClassName** is immutable; if the live PVC uses `longhorn`, keep `persistence.storageClass: longhorn` in values to match Helm upgrades.
- Admin password: `kubectl get secret -n jenkins jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d; echo`

### Example (httpbin)

Plain manifests under `apps/example/` — apply as needed for smoke tests.

## Secrets and Git

- Tunnel token and similar credentials live in **Kubernetes Secrets**, not in this repo.
- `.gitignore` excludes common secret filenames and patterns; review before pushing.

## Hostnames

Manifests use **`*.aakshranjan.com`** for ingress and tunnel examples. Replace with your domain or use placeholders if you clone this repo for a public Git remote.

## License

See `LICENSE`.
