#!/bin/bash
#
# Install Kubernetes learning tools (no sudo required)
# Tools: kubectl, minikube, helm
# Prerequisite: Docker already installed
#
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Architecture: $ARCH"
echo "Install directory: $INSTALL_DIR"
echo ""

mkdir -p "$INSTALL_DIR"

# --- kubectl ---
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
curl -fsSL -o "$INSTALL_DIR/kubectl" \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
chmod +x "$INSTALL_DIR/kubectl"
echo "  kubectl $KUBECTL_VERSION installed"

# --- minikube ---
echo "Installing minikube..."
curl -fsSL -o "$INSTALL_DIR/minikube" \
    "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${ARCH}"
chmod +x "$INSTALL_DIR/minikube"
echo "  minikube installed"

# --- helm ---
echo "Installing helm..."
HELM_LATEST=$(curl -fsSL https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -fsSL "https://get.helm.sh/helm-${HELM_LATEST}-linux-${ARCH}.tar.gz" | tar xz -C /tmp
mv /tmp/linux-${ARCH}/helm "$INSTALL_DIR/helm"
rm -rf /tmp/linux-${ARCH}
chmod +x "$INSTALL_DIR/helm"
echo "  helm $HELM_LATEST installed"

# --- Update PATH ---
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "" >> "$HOME/.bashrc"
    echo '# Kubernetes tools' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo ""
    echo "Added $INSTALL_DIR to PATH in ~/.bashrc"
    echo "Run: source ~/.bashrc"
    echo ""
    export PATH="$INSTALL_DIR:$PATH"
fi

# --- Verify ---
echo ""
echo "=== Installed versions ==="
kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | head -1
minikube version --short
helm version --short
echo ""

# --- Next steps ---
echo "=== Next steps ==="
echo "1. source ~/.bashrc          # reload PATH (if first install)"
echo "2. minikube start             # start a local Kubernetes cluster"
echo "3. kubectl get nodes          # verify the cluster is running"
