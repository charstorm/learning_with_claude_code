#!/bin/bash
#
# Check if all required Kubernetes learning tools are installed
#
PASS=0
FAIL=0

check() {
    local tool=$1
    if command -v "$tool" &>/dev/null; then
        local version
        case "$tool" in
            kubectl)  version=$(kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | head -1 | awk '{print $2}') ;;
            minikube) version=$(minikube version --short 2>/dev/null) ;;
            helm)     version=$(helm version --short 2>/dev/null) ;;
            docker)   version=$(docker --version 2>/dev/null) ;;
        esac
        echo "  OK  $tool  ($version)"
        ((PASS++))
    else
        echo "  MISSING  $tool"
        ((FAIL++))
    fi
}

echo "Checking tools..."
echo ""
check docker
check kubectl
check minikube
check helm
echo ""
echo "Result: $PASS found, $FAIL missing"

if [ "$FAIL" -gt 0 ]; then
    echo "Run ./install_k8s_tools.sh to install missing tools."
    exit 1
fi
