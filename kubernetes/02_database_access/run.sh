#!/bin/bash
#
# Deploy PostgreSQL and the visit-counter app to minikube
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

# Build the app image
echo ""
echo "Building visit-counter-app image..."
docker build -t visit-counter-app "$DIR"

# Load into minikube
echo ""
echo "Loading visit-counter-app image into minikube..."
minikube image load visit-counter-app

# Deploy PostgreSQL first
echo ""
echo "Deploying PostgreSQL..."
kubectl apply -f "$DIR/postgres.yaml"

echo ""
echo "Waiting for PostgreSQL to be ready..."
kubectl rollout status deployment/postgres --timeout=90s

# Deploy the app
echo ""
echo "Deploying visit-counter app..."
kubectl apply -f "$DIR/app.yaml"

echo ""
echo "Waiting for visit-counter to be ready..."
kubectl rollout status deployment/visit-counter --timeout=90s

# Show status
echo ""
echo "=== Pods ==="
kubectl get pods -l 'app in (visit-counter, postgres)'

echo ""
echo "=== Services ==="
kubectl get service visit-counter postgres

echo ""
echo "=== PersistentVolumeClaim ==="
kubectl get pvc postgres-pvc

# Get the URL
echo ""
echo "Getting service URL..."
URL=$(minikube service visit-counter --url)
echo "$URL"

echo ""
echo "=== Next steps ==="
echo "[test]        curl $URL"
echo "[health]      curl $URL/health"
echo "[status]      ./status.sh"
echo "[db]          ./db.sh"
echo "[logs]        kubectl logs -l app=visit-counter -f --prefix"
echo "[persistence] ./test_persistence.sh"
echo "[stop]        ./stop.sh"
