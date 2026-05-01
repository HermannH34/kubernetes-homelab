#!/bin/bash
set -e  # Stop on error

echo "🗑️  Deleting existing cluster..."
k3d cluster delete homelab 2>/dev/null || echo "No cluster to delete"

echo "🚀 Creating new cluster with port mappings..."
k3d cluster create homelab \
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

echo "🎯 Bootstrapping Flux CD..."
flux bootstrap github \
  --owner=HermannH34 \
  --repository=kubernetes-homelab \
  --branch=HermannH34/image-version-question \
  --path=clusters/staging \
  --personal

echo "⏳ Waiting for Flux deployment..."
kubectl wait --for=condition=Ready pods --all -n flux-system --timeout=120s

echo "📊 Cluster status:"
kubectl get nodes
kubectl get pods -n flux-system

echo ""
echo "✅ Cluster ready!"