#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="v1.11.1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INGRESS_FILE="${SCRIPT_DIR}/longhorn-ingress.yaml"
STORAGECLASS_2R_FILE="${SCRIPT_DIR}/storageclass-2-replicas.yaml"

helm repo add longhorn https://charts.longhorn.io
helm repo update

kubectl create namespace longhorn-system --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --version "${CHART_VERSION}"

kubectl apply -f "${STORAGECLASS_2R_FILE}"
kubectl apply -f "${INGRESS_FILE}"