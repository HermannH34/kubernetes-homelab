#!/usr/bin/env bash

set -euo pipefail

echo "======================================"
echo "🔍 Kubernetes Cluster Health Check"
echo "⏱ $(date)"
echo "======================================"

# 1. Node health
echo -e "\n📦 [1] Nodes status"
kubectl get nodes

# 2. API server health
echo -e "\n🧠 [2] API Server readiness"
if kubectl get --raw='/readyz?verbose' | grep -E '\[+\]|readyz' >/dev/null; then
  echo "✅ API Server is ready"
else
  echo "❌ API Server NOT ready"
fi

# 3. Failing pods
echo -e "\n🚨 [3] Failing Pods"
kubectl get pods -A \
  --field-selector=status.phase!=Running,status.phase!=Succeeded \
  | head -30

# 4. Resource usage
echo -e "\n📊 [4] Resource usage (nodes)"
kubectl top nodes || echo "⚠️ Metrics server not available"

# 5. Recent warning events
echo -e "\n⚠️ [5] Recent warning events"
kubectl get events -A \
  --sort-by='.lastTimestamp' \
  --field-selector type=Warning \
  | tail -20

echo -e "\n======================================"
echo "✅ Check completed"
echo "======================================"