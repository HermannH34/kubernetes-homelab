#!/bin/bash
set -e

# Setup K3s + Flux on OVH VPS
# Idempotent bootstrap script for VPS deployment
# Usage: ./setup-cluster-ovh.sh <VPS_HOST> <VPS_USER> <AGE_AGEKEY_FILE> <GITHUB_TOKEN>

VPS_HOST="${1:-}"
VPS_USER="${2:-ubuntu}"
AGE_AGEKEY_FILE="${3:-./age.agekey}"
GITHUB_TOKEN="${4:-}"
SSH_KEY="${SSH_KEY:- }"

# Validation
if [ -z "$VPS_HOST" ]; then
  echo "❌ Error: VPS_HOST not provided"
  echo "Usage: $0 <VPS_HOST> [VPS_USER] [AGE_AGEKEY_FILE] [GITHUB_TOKEN]"
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌ Error: GITHUB_TOKEN not provided (set via arg or GITHUB_TOKEN env var)"
  exit 1
fi

if [ ! -f "$AGE_AGEKEY_FILE" ]; then
  echo "❌ Error: Age key file not found: $AGE_AGEKEY_FILE"
  exit 1
fi

echo "📋 Configuration:"
echo "  VPS_HOST: $VPS_HOST"
echo "  VPS_USER: $VPS_USER"
echo "  AGE_AGEKEY_FILE: $AGE_AGEKEY_FILE"
echo ""

# Helper function for remote commands
run_remote() {
  local cmd="$1"
  ssh -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "set -e; $cmd"
}

# ============================================================================
# Step 1: Check if K3s is already installed
# ============================================================================
echo "🔍 Checking if K3s is installed..."
if run_remote "[ -f /usr/local/bin/k3s ]"; then
  echo "✅ K3s already installed"
  K3S_INSTALLED=true
else
  echo "📥 K3s not found, will install"
  K3S_INSTALLED=false
fi

# ============================================================================
# Step 2: Install K3s (if needed)
# ============================================================================
if [ "$K3S_INSTALLED" = false ]; then
  echo "🚀 Installing K3s..."
  run_remote "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--disable traefik' sh -"
  echo "✅ K3s installed"
else
  echo "⏭️  Skipping K3s installation (already present)"
fi

# ============================================================================
# Step 3: Start K3s service
# ============================================================================
echo "🔄 Starting K3s service..."
run_remote "sudo systemctl start k3s && sudo systemctl enable k3s"
echo "✅ K3s service started"

# ============================================================================
# Step 4: Wait for K3s to be ready
# ============================================================================
echo "⏳ Waiting for K3s node to be Ready (max 5 minutes)..."
run_remote "for i in {1..30}; do
  STATUS=\$(/usr/local/bin/k3s kubectl get nodes -o jsonpath='{.items[0].status.conditions[?(@.type==\"Ready\")].status}' 2>/dev/null || echo '')
  if [ \"\$STATUS\" = \"True\" ]; then
    echo 'Node is Ready'
    exit 0
  fi
  echo \"Waiting... (\$i/30)\"
  sleep 10
done
echo 'Node failed to become Ready'
exit 1"
echo "✅ K3s node is Ready"

# ============================================================================
# Step 5: Check if flux-system namespace exists
# ============================================================================
echo "🔍 Checking flux-system namespace..."
if run_remote "/usr/local/bin/k3s kubectl get namespace flux-system >/dev/null 2>&1"; then
  echo "✅ flux-system namespace already exists"
  FLUX_NS_EXISTS=true
else
  echo "📝 Creating flux-system namespace..."
  run_remote "/usr/local/bin/k3s kubectl create namespace flux-system"
  echo "✅ flux-system namespace created"
  FLUX_NS_EXISTS=false
fi

# ============================================================================
# Step 6: Create SOPS Age secret (idempotent)
# ============================================================================
echo "🔐 Setting up SOPS Age secret..."
AGE_KEY_CONTENT=$(cat "$AGE_AGEKEY_FILE")
run_remote "cat <<'EOF' | /usr/local/bin/k3s kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: sops-age
  namespace: flux-system
type: Opaque
stringData:
  age.agekey: |
$(echo "$AGE_KEY_CONTENT" | sed 's/^/    /')
EOF"
echo "✅ SOPS Age secret configured"

# ============================================================================
# Step 7: Check if Flux is already bootstrapped
# ============================================================================
echo "🔍 Checking if Flux is bootstrapped..."
if run_remote "/usr/local/bin/k3s kubectl get deployment flux-controller-manager -n flux-system >/dev/null 2>&1"; then
  echo "✅ Flux already bootstrapped"
  FLUX_BOOTSTRAPPED=true
else
  echo "📋 Flux not found, will bootstrap"
  FLUX_BOOTSTRAPPED=false
fi

# ============================================================================
# Step 8: Bootstrap Flux (if needed)
# ============================================================================
if [ "$FLUX_BOOTSTRAPPED" = false ]; then
  echo "🎯 Bootstrapping Flux with GitHub..."
  run_remote "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml && \
export GITHUB_TOKEN='$GITHUB_TOKEN' && \
/usr/local/bin/flux bootstrap github \
  --owner=HermannH34 \
  --repository=kubernetes-homelab \
  --branch=main \
  --path=clusters/staging \
  --personal"
  echo "✅ Flux bootstrapped"
else
  echo "⏭️  Skipping Flux bootstrap (already done)"
fi

# ============================================================================
# Step 9: Wait for Flux components to be ready
# ============================================================================
echo "⏳ Waiting for Flux components to be ready (max 5 minutes)..."
run_remote "for i in {1..30}; do
  COUNT=\$(/usr/local/bin/k3s kubectl get deployment -n flux-system -o jsonpath='{.items[*].status.readyReplicas}' 2>/dev/null | grep -o '[0-9]' | head -1)
  if [ ! -z \"\$COUNT\" ] && [ \"\$COUNT\" -gt 0 ]; then
    echo 'Flux components are ready'
    exit 0
  fi
  echo \"Waiting for Flux... (\$i/30)\"
  sleep 10
done
echo 'Flux components did not become ready in time'
exit 1"
echo "✅ Flux components are ready"

# ============================================================================
# Step 10: Verification
# ============================================================================
echo ""
echo "📊 Cluster Status:"
echo ""
echo "--- Nodes ---"
run_remote "/usr/local/bin/k3s kubectl get nodes -o wide"
echo ""
echo "--- Flux System Pods ---"
run_remote "/usr/local/bin/k3s kubectl get pods -n flux-system"
echo ""
echo "--- Flux Kustomizations ---"
run_remote "/usr/local/bin/k3s flux get all -A 2>/dev/null || echo '(Flux not ready yet)'"
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "✅ Bootstrap complete!"
echo ""
echo "Next steps:"
echo "1. Verify Flux reconciliation: ssh $VPS_USER@$VPS_HOST 'sudo /usr/local/bin/k3s flux get all -A'"
echo "2. Get kubeconfig: ssh $VPS_USER@$VPS_HOST 'sudo cat /etc/rancher/k3s/k3s.yaml' > ~/.kube/config.ovh"
echo "3. Edit kubeconfig: change server: https://127.0.0.1:6443 → https://$VPS_HOST:6443"
echo ""
