#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="v1.20.0"

helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version "${CHART_VERSION}" \
  --set installCRDs=true