#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="82.13.6"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version "${CHART_VERSION}"