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
if [ -f "age.agekey" ]; then
  cat age.agekey | kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=age.agekey=/dev/stdin
  echo "✅ SOPS secret created"
else
  echo "⚠️  age.agekey file not found - Skipped"
fi

echo "🎯 Bootstrapping Flux CD..."
flux bootstrap github \
  --owner=HermannH34 \
  --repository=kubernetes-homelab \
  --branch=main \
  --path=clusters/staging \
  --personal

echo "⏳ Waiting for Flux deployment..."
kubectl wait --for=condition=Ready pods --all -n flux-system --timeout=120s

echo "📊 Cluster status:"
kubectl get nodes
kubectl get pods -n flux-system

echo ""
echo "✅ Cluster ready!"