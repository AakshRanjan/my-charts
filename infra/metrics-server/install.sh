#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/values.yaml"
CHART_VERSION="3.13.0"

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --version "${CHART_VERSION}" \
  -f "${VALUES_FILE}"