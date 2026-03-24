#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="4.15.1"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --version "${CHART_VERSION}"