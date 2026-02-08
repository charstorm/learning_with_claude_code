# Kubernetes Learning Session - 02 Database Access

## What we did

### 1. Built a FastAPI visit-counter app
- `app.py` — FastAPI server with `GET /` (increments & returns visit count) and `GET /health` (verifies DB connectivity)
- Reads DB config from environment variables (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`)
- Creates the `visits` table automatically on startup

### 2. Deployed PostgreSQL with persistent storage
- `postgres.yaml` — PersistentVolumeClaim (1Gi) + Deployment (postgres:16-alpine) + ClusterIP Service
- Data stored on a PersistentVolume, survives pod restarts
- `subPath: pgdata` used to avoid `lost+found` conflicts in the mount
- Health checks via `pg_isready`

### 3. Deployed the app with ConfigMap and Secret
- `app.yaml` — ConfigMap (DB host/port/name) + Secret (DB user/password) + Deployment (2 replicas) + NodePort Service
- `envFrom` injects all config/secret keys as environment variables
- `imagePullPolicy: Never` for locally loaded images
- `stringData` in Secret for human-readable YAML (Kubernetes stores it base64-encoded)

## Key concepts covered

| Concept | What it is |
|---------|------------|
| **PersistentVolumeClaim (PVC)** | Requests storage from the cluster. Minikube auto-provisions a PersistentVolume. Mounted into the pod as a directory. |
| **PersistentVolume (PV)** | The actual storage backing a PVC. Created automatically by minikube's default provisioner. |
| **Secret** | Stores sensitive data (passwords). Base64-encoded, not encrypted. Injected into pods as env vars. |
| **ConfigMap** | Stores non-sensitive config (DB host, port). Also injected as env vars. |
| **ClusterIP Service** | Internal-only service. Postgres doesn't need external access — only app pods talk to it. |
| **envFrom** | Injects all keys from a ConfigMap or Secret as environment variables at once. |
| **subPath** | Mounts a subdirectory of a volume instead of the root. Needed for Postgres to avoid `lost+found`. |
| **Stateful vs Stateless** | App pods are stateless (no local data). Postgres is stateful (needs persistent disk). |

## How the app finds Postgres

1. ConfigMap sets `DB_HOST=postgres` (the Service name)
2. Kubernetes DNS resolves `postgres` → ClusterIP Service → Postgres pod
3. Secret provides `DB_USER` and `DB_PASSWORD` as env vars

## Useful commands

```bash
# Deploy & tear down
./run.sh                    # deploy everything
./stop.sh                   # delete resources
./stop.sh --all             # also stop minikube

# Inspect
./status.sh                 # show all resources
./db.sh                     # show visit count and recent rows
./db.sh query "SELECT ..."  # run custom SQL

# Test persistence
./test_persistence.sh       # delete postgres pod, verify data survives

# Pods & logs
kubectl get pods -l 'app in (visit-counter, postgres)' -o wide
kubectl logs -l app=visit-counter -f --prefix
kubectl describe pod <pod-name>

# Persistent storage
kubectl get pvc             # show PersistentVolumeClaims
kubectl get pv              # show PersistentVolumes

# ConfigMap & Secret
kubectl get configmap visit-counter-config -o yaml
kubectl get secret visit-counter-secret -o yaml
```

## Files in this directory

```
kubernetes/02_database_access/
  app.py                 # FastAPI visit-counter app
  requirements.txt       # Python dependencies (fastapi, uvicorn, psycopg2-binary)
  Dockerfile             # container image definition
  postgres.yaml          # K8s: PVC + Deployment + ClusterIP Service for PostgreSQL
  app.yaml               # K8s: ConfigMap + Secret + Deployment + NodePort Service for app
  run.sh                 # deploy everything to minikube
  stop.sh                # tear down (--all to also stop minikube)
  status.sh              # show all resources at a glance
  db.sh                  # inspect DB: row counts, recent visits, custom queries
  test_persistence.sh    # prove data survives pod deletion
  chat_summary.md        # this file
```
