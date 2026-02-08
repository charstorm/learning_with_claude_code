#!/bin/bash
#
# Show status of all database-access resources
#
set -euo pipefail

echo "=== Pods ==="
kubectl get pods -l 'app in (visit-counter, postgres)' -o wide

echo ""
echo "=== Deployments ==="
kubectl get deployments visit-counter postgres

echo ""
echo "=== Services ==="
kubectl get services visit-counter postgres

echo ""
echo "=== ConfigMap ==="
kubectl get configmap visit-counter-config -o jsonpath='{.data}' | python3 -m json.tool

echo ""
echo "=== Secret (keys only — values are base64-encoded) ==="
kubectl get secret visit-counter-secret -o jsonpath='{.data}' \
  | python3 -c "import sys,json; d=json.load(sys.stdin); [print(f'  {k}') for k in d]"

echo ""
echo "=== PersistentVolumeClaim ==="
kubectl get pvc postgres-pvc

echo ""
echo "=== PersistentVolume (auto-provisioned) ==="
kubectl get pv

echo ""
echo "=== Next steps ==="
echo "[describe] kubectl describe pod <pod-name>"
echo "[logs]     kubectl logs -l app=visit-counter -f --prefix"
echo "[db]       ./db.sh"
