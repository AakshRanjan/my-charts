#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="82.13.6"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/values.yaml"
INGRESS_FILE="${SCRIPT_DIR}/grafana-ingress.yaml"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version "${CHART_VERSION}" \
  -f "${VALUES_FILE}"

kubectl apply -f "${INGRESS_FILE}"