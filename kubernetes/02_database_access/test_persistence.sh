#!/bin/bash
#
# Test that data persists across postgres pod restarts
# Demonstrates PersistentVolumeClaim behavior
#
set -euo pipefail

# Get the app URL
URL=$(minikube service visit-counter --url)

# Step 1: Create some visits and record the count
echo "Step 1: Creating visits..."
curl -s "$URL" > /dev/null
curl -s "$URL" > /dev/null
BEFORE=$(curl -s "$URL" | python3 -c "import sys,json; print(json.load(sys.stdin)['visits'])")
echo "  Visit count before restart: $BEFORE"

# Step 2: Delete the postgres pod
echo ""
echo "Step 2: Deleting postgres pod..."
kubectl delete pod -l app=postgres
echo "  Pod deleted. Kubernetes will recreate it automatically."

# Step 3: Wait for the new pod to be ready
echo ""
echo "Step 3: Waiting for postgres to recover..."
kubectl rollout status deployment/postgres --timeout=90s

# Step 4: Give the app a moment to reconnect, then query
echo ""
echo "Step 4: Verifying data survived..."
sleep 3
AFTER=$(curl -s "$URL" | python3 -c "import sys,json; print(json.load(sys.stdin)['visits'])")
echo "  Visit count after restart: $AFTER"

# Step 5: Report result
echo ""
if [ "$AFTER" -gt "$BEFORE" ]; then
    echo "SUCCESS: Data persisted! Count went from $BEFORE to $AFTER."
    echo "The PersistentVolumeClaim kept the data safe across pod restarts."
else
    echo "UNEXPECTED: Count did not increase. Something may be wrong."
fi

echo ""
echo "=== Next steps ==="
echo "[db]     ./db.sh"
echo "[status] ./status.sh"
echo "[stop]   ./stop.sh"
