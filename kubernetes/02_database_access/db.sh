#!/bin/bash
#
# Inspect the PostgreSQL database
# Usage:
#   ./db.sh              # show visit count and recent rows
#   ./db.sh query "SQL"  # run a custom SQL query
#
set -euo pipefail

# Find the postgres pod
POD=$(kubectl get pod -l app=postgres -o jsonpath='{.items[0].metadata.name}')

run_sql() {
    kubectl exec "$POD" -- psql -U postgres -d visits -c "$1"
}

# Custom query mode
if [ "${1:-}" = "query" ]; then
    QUERY="${2:?Usage: ./db.sh query \"SELECT ...\"}"
    run_sql "$QUERY"
    exit 0
fi

# Default: show overview
echo "=== Tables ==="
run_sql "\dt"

echo ""
echo "=== Total visits ==="
run_sql "SELECT COUNT(*) AS total_visits FROM visits;"

echo ""
echo "=== Last 10 visits ==="
run_sql "SELECT * FROM visits ORDER BY id DESC LIMIT 10;"

echo ""
echo "=== Next steps ==="
echo "[custom]      ./db.sh query \"SELECT COUNT(*) FROM visits\""
echo "[persistence] ./test_persistence.sh"
echo "[status]      ./status.sh"
