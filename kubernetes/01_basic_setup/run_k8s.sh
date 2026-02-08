#!/bin/bash
#
# Start minikube and deploy the hello-k8s app
#
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

# Start minikube if not running
if ! minikube status &>/dev/null; then
    echo "Starting minikube..."
    minikube start --driver=docker
else
    echo "Minikube is already running."
fi

# Load the local Docker image into minikube
echo ""
echo "Loading hello-k8s image into minikube..."
minikube image load hello-k8s

# Apply the deployment
echo ""
echo "Applying deployment..."
kubectl apply -f "$DIR/deployment.yaml"

# Wait for pods to be ready
echo ""
echo "Waiting for pods to be ready..."
kubectl rollout status deployment/hello-k8s --timeout=60s

# Show status
echo ""
echo "=== Pods ==="
kubectl get pods -l app=hello-k8s

echo ""
echo "=== Service ==="
kubectl get service hello-k8s

# Get the URL
echo ""
echo "Opening service URL..."
minikube service hello-k8s --url

echo ""
echo "[test] Use the URL above to test: curl <url>"
echo "[logs] Use 'kubectl logs -l app=hello-k8s -f' to see the logs"
