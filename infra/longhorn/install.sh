#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="v1.11.1"

helm repo add longhorn https://charts.longhorn.io
helm repo update

kubectl create namespace longhorn-system --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --version "${CHART_VERSION}"