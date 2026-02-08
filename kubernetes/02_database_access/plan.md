# 02 Database Access — Plan

## Goal
Deploy a FastAPI app and PostgreSQL as **separate containers** in Kubernetes. The app connects to Postgres, stores and retrieves data. Data survives pod restarts thanks to persistent storage.

## Architecture

```
                    ┌──────────────────────────────────┐
                    │         minikube cluster          │
                    │                                   │
 browser/curl ──►  │  Service (NodePort)                │
                    │      │                            │
                    │      ▼                            │
                    │  App Deployment (2 replicas)      │
                    │  ┌─────────┐  ┌─────────┐        │
                    │  │ app pod │  │ app pod │        │
                    │  └────┬────┘  └────┬────┘        │
                    │       │            │              │
                    │       ▼            ▼              │
                    │  Service (ClusterIP, internal)    │
                    │      │                            │
                    │      ▼                            │
                    │  Postgres Deployment (1 replica)  │
                    │  ┌──────────────┐                 │
                    │  │ postgres pod │◄── PVC (1Gi)   │
                    │  └──────────────┘                 │
                    └──────────────────────────────────┘
```

## Docker images (2 separate images)

| Image | Base | Purpose |
|-------|------|---------|
| `visit-counter-app` | python:3.12-slim | FastAPI app with psycopg2 |
| `postgres:16-alpine` | official image | No custom build needed |

## Files to create

### App files
| File | Description |
|------|-------------|
| `app.py` | FastAPI app — `GET /` increments & returns visit count, `GET /health` health check. Reads DB connection from env vars. Creates `visits` table on startup. |
| `requirements.txt` | fastapi, uvicorn, psycopg2-binary |
| `Dockerfile` | Builds `visit-counter-app` image |

### Kubernetes manifests
| File | Contains | Notes |
|------|----------|-------|
| `postgres.yaml` | PersistentVolumeClaim + Deployment + ClusterIP Service | PVC uses minikube's default storage provisioner. ClusterIP = internal only. |
| `app.yaml` | ConfigMap + Secret + Deployment + NodePort Service | ConfigMap for DB_HOST/DB_PORT/DB_NAME. Secret for DB_USER/DB_PASSWORD. |

### Shell scripts
| File | What it does |
|------|-------------|
| `run.sh` | Start minikube → build app image → load into minikube → apply postgres.yaml → wait → apply app.yaml → wait → print URL |
| `stop.sh` | Delete app + postgres resources. `--all` flag also stops minikube. |

## New concepts

| Concept | Explanation |
|---------|-------------|
| **PersistentVolumeClaim (PVC)** | Requests storage from the cluster. Minikube auto-creates a PersistentVolume. Mounted into the Postgres pod at `/var/lib/postgresql/data`. |
| **Secret** | Stores sensitive data (DB password) as base64. Injected into pods as env vars. Not truly encrypted — just a K8s convention for separating secrets from config. |
| **ConfigMap** | Stores non-sensitive config (DB host, port, name). Also injected as env vars. |
| **ClusterIP Service** | Only reachable inside the cluster. Postgres doesn't need external access — only the app talks to it. |
| **Stateful vs Stateless** | App pods are stateless (no local data). Postgres is stateful (needs persistent disk). |

## How the app finds Postgres
- ConfigMap sets `DB_HOST=postgres` (the Service name), `DB_PORT=5432`, `DB_NAME=visits`
- Secret sets `DB_USER=postgres`, `DB_PASSWORD=postgres`
- Kubernetes DNS resolves `postgres` to the ClusterIP Service → routes to the Postgres pod

## Verification plan
```bash
./run.sh                              # deploy everything
curl <url>                            # returns {"visits": 1}
curl <url>                            # returns {"visits": 2}
kubectl get pvc                       # shows Bound PVC
kubectl delete pod -l app=postgres    # kill postgres pod
# K8s auto-recreates it, PVC keeps the data
curl <url>                            # returns {"visits": 3} — data survived!
./stop.sh                             # cleanup
```
