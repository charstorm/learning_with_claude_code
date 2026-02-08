#!/bin/bash
#
# Tear down the visit-counter and PostgreSQL deployment
# Usage:
#   ./stop.sh        # delete app & postgres resources only
#   ./stop.sh --all  # also stop minikube
#
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Deleting visit-counter app..."
kubectl delete -f "$DIR/app.yaml" --ignore-not-found

echo "Deleting PostgreSQL..."
kubectl delete -f "$DIR/postgres.yaml" --ignore-not-found

if [ "${1:-}" = "--all" ]; then
    echo "Stopping minikube..."
    minikube stop
fi

echo "Done."
