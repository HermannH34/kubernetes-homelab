#!/bin/bash
set -e  # Stop on error

BRANCH="${1:-main}"
CLUSTER_NAME="${2:-homelab}"

echo "🗑️  Deleting existing cluster..."
k3d cluster delete "$CLUSTER_NAME" 2>/dev/null || echo "No cluster to delete"

echo "🚀 Creating new cluster with port mappings..."
k3d cluster create "$CLUSTER_NAME" \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer"

echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo "🔐 Creating flux-system namespace..."
kubectl create namespace flux-system

echo "🔑 Creating SOPS secret..."
AGE_KEY_FILE="${HOME}/.config/sops/age/keys.txt"
if [ -f "$AGE_KEY_FILE" ]; then
  kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=age.agekey="$AGE_KEY_FILE"
  echo "✅ SOPS secret created"
else
  echo "⚠️  Age key not found at $AGE_KEY_FILE - Skipped"
fi

echo "🎯 Bootstrapping Flux CD on branch: $BRANCH..."
flux bootstrap github \
  --owner=HermannH34 \
  --repository=kubernetes-homelab \
  --branch="$BRANCH" \
  --path=clusters/staging \
  --components-extra=image-reflector-controller,image-automation-controller \
  --personal

echo "🔧 Restoring gotk-components.yaml and gotk-sync.yaml from main..."
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"
git fetch origin
git checkout origin/main -- clusters/staging/flux-system/gotk-components.yaml
# Ensure gotk-sync.yaml always points to main to avoid overwriting prod config
sed -i '' "s|branch: $BRANCH|branch: main|g" clusters/staging/flux-system/gotk-sync.yaml
if ! git diff --quiet clusters/staging/flux-system/; then
  git add clusters/staging/flux-system/gotk-components.yaml clusters/staging/flux-system/gotk-sync.yaml
  git commit -m "chore: restore flux manifests to main after k3d bootstrap"
  git push
  echo "✅ Flux manifests restored"
else
  echo "✅ Flux manifests already correct, no changes needed"
fi

echo "⏳ Waiting for Flux deployment..."
kubectl wait --for=condition=Ready pods --all -n flux-system --timeout=120s

echo "📊 Cluster status:"
kubectl get nodes
kubectl get pods -n flux-system

echo ""
echo "✅ Cluster ready! (branch: $BRANCH, cluster: $CLUSTER_NAME)"
echo ""
echo "Usage:"
echo "  ./setup-cluster-k3d.sh                                    # main"
echo "  ./setup-cluster-k3d.sh HermannH34/my-feature             # feature branch"
echo "  ./setup-cluster-k3d.sh HermannH34/my-feature my-cluster  # named cluster"
