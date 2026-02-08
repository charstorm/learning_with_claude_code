#!/bin/bash
#
# Build and run the hello-k8s Docker container
# Usage:
#   ./run_docker.sh        # build & run
#   ./run_docker.sh stop   # stop & remove container
#
set -euo pipefail

IMAGE="hello-k8s"
CONTAINER="hello-k8s"
DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "${1:-}" = "stop" ]; then
    echo "Stopping $CONTAINER..."
    docker stop "$CONTAINER" 2>/dev/null && docker rm "$CONTAINER" 2>/dev/null
    echo "Done."
    exit 0
fi

echo "Building image: $IMAGE"
docker build -t "$IMAGE" "$DIR"

echo ""
echo "Running container: $CONTAINER"
docker run -d --name "$CONTAINER" -p 8000:8000 "$IMAGE"

echo ""
echo "Container is running. Test it:"
echo "  curl http://localhost:8000"
echo "  curl http://localhost:8000/health"
echo ""
echo "To stop: ./run_docker.sh stop"
