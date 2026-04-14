# Cluster Health Check

Script for diagnosing the Kubernetes cluster.

## Usage

```bash
./cluster-health.sh
```

## What it checks

| # | Check | Command |
|---|-------|---------|
| 1 | Node status | `kubectl get nodes` |
| 2 | API server readiness | `/readyz` endpoint |
| 3 | Failing pods | `kubectl get pods -A` |
| 4 | Resource usage | `kubectl top nodes` |
| 5 | Recent Warning events | `kubectl get events` |

## Operational checklist

This table summarizes the checks to perform according to their frequency to keep the cluster healthy and anticipate issues before they impact workloads.

| Frequency | Check | Key command | Action if issue |
|-----------|-------|-------------|-----------------|
| Daily | Nodes Ready | `kubectl get nodes` | Investigate NotReady node |
| Daily | API server healthy | `kubectl get --raw='/readyz?verbose'` | Check logs for `[-]` component |
| Daily | Failing pods | `kubectl get pods -A --field-selector=status.phase!=Running,...` | Investigate or restart |
| Daily | Resource usage | `kubectl top nodes` | Investigate if operational thresholds exceeded |
| Daily | Warning events | `kubectl get events -A --field-selector type=Warning` | Identify recurring patterns |
| Weekly | Completed pods/jobs | `kubectl get pods --field-selector=status.phase==Succeeded` | Configure TTL, clean up if needed |
| Weekly | Orphaned ReplicaSets | `kubectl get rs -A` | Adjust `revisionHistoryLimit` |
| Weekly | Namespace quotas | `kubectl get resourcequota -A` | Adjust if close to limit |
| Weekly | Disk pressure | `kubectl describe node` (DiskPressure) | Targeted cleanup if confirmed |
| Monthly | Control plane certificates | `kubeadm certs check-expiration` | Renew if < 30 days |
| Monthly | Ingress certificates | `kubectl get certificates -A` | Check cert-manager |
| Monthly | Capacity trends | `kubectl top nodes` (history) | Plan adjustments |

## Prerequisites

- `kubectl` configured with cluster access
- Metrics server installed for check #4 — without it, a warning is displayed but the script continues
