#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="5.9.9"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/values.yaml"

helm repo add jenkins https://charts.jenkins.io
helm repo update

kubectl create namespace jenkins --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins \
  --version "${CHART_VERSION}" \
  -f "${VALUES_FILE}"

echo "Admin password:"
echo "  kubectl get secret -n jenkins jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d; echo"
