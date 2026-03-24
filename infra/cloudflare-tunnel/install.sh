#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGMAP_FILE="${SCRIPT_DIR}/configmap.yaml"
DEPLOYMENT_FILE="${SCRIPT_DIR}/deployment.yaml"

kubectl create namespace cloudflare --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f "${CONFIGMAP_FILE}"
kubectl apply -f "${DEPLOYMENT_FILE}"
kubectl rollout restart deployment/cloudflare-tunnel -n cloudflare