# Kubernetes Learning Session - 01 Basic Setup

## What we did

### 1. Installed tools
- Created `install_k8s_tools.sh` — downloads kubectl, minikube, helm as binaries to `~/.local/bin` (no sudo)
- Created `check_tools.sh` — verifies all tools (docker, kubectl, minikube, helm) are installed and prints versions

### 2. Built a FastAPI app + Docker image
- `hello_world.py` — simple FastAPI server with `GET /` and `GET /health` endpoints
- `requirements.txt` — fastapi, uvicorn
- `Dockerfile` — python:3.12-slim base, installs deps, runs uvicorn on port 8000
- `run_docker.sh` — builds and runs the container (`./run_docker.sh stop` to tear down)

### 3. Deployed to Kubernetes via minikube
- `deployment.yaml` — Kubernetes manifest with:
  - **Deployment**: 2 replicas of hello-k8s, health checks on `/health`
  - **Service**: NodePort type, exposes port 8000
  - `imagePullPolicy: Never` so it uses the locally loaded image
- `run_k8s.sh` — starts minikube, loads the Docker image, applies the manifest, prints the service URL
- `stop_k8s.sh` — deletes deployment/service (`--all` flag also stops minikube)

## Key concepts covered

| Concept | What it is |
|---------|-----------|
| **Pod** | Smallest unit in K8s. A wrapper around one or more containers. Each pod gets its own IP. |
| **Deployment** | Manages pods. Ensures the desired number of replicas are running. Handles rolling updates. |
| **Service** | Stable entry point to pods. Routes traffic using label selectors. Types: ClusterIP, NodePort, LoadBalancer. |
| **Namespace** | Logical grouping of resources (like folders). We used `default`. |
| **Labels** | Key-value pairs (`app: hello-k8s`) that connect Services to Pods. |

## Useful commands

```bash
# Pods
kubectl get pods                           # list pods
kubectl get pods -o wide                   # list with IPs
kubectl describe pod <pod-name>            # detailed info
kubectl exec -it <pod-name> -- /bin/bash   # shell into pod

# Logs
kubectl logs deployment/hello-k8s -f                          # follow logs (one pod)
kubectl logs -l app=hello-k8s -f --all-containers --prefix    # all pods, prefixed

# Cluster
minikube start             # start cluster
minikube stop              # stop cluster
minikube service hello-k8s --url   # get service URL
```

## Files in this directory

```
kubernetes/01_basic_setup/
  install_k8s_tools.sh   # install kubectl, minikube, helm
  check_tools.sh         # verify tools are installed
  hello_world.py         # FastAPI app
  requirements.txt       # Python dependencies
  Dockerfile             # container image definition
  run_docker.sh          # build & run with plain Docker
  deployment.yaml        # Kubernetes Deployment + Service manifest
  run_k8s.sh             # deploy to minikube
  stop_k8s.sh            # tear down deployment
  chat_summary.md        # this file
```
