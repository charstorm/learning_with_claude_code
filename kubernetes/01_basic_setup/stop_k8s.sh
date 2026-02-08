#!/bin/bash
#
# Tear down the hello-k8s deployment
# Usage:
#   ./stop_k8s.sh        # delete deployment & service only
#   ./stop_k8s.sh --all  # also stop minikube
#
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Deleting deployment and service..."
kubectl delete -f "$DIR/deployment.yaml" --ignore-not-found

if [ "${1:-}" = "--all" ]; then
    echo "Stopping minikube..."
    minikube stop
fi

echo "Done."
