# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A declarative Kubernetes homelab managed entirely through GitOps using FluxCD. All changes to cluster state are made by committing to this repository — there is no manual `kubectl apply` workflow for persistent changes.

## Common Commands

### Local Development Cluster
```bash
# Bootstrap a local K3d cluster with FluxCD (full setup)
./setup-cluster-k3d.sh
```

### SOPS Secret Management
```bash
# Encrypt a new secret file
sops --encrypt --in-place secret.yaml

# Edit an encrypted secret
sops secret.yaml

# Decrypt for inspection (do not commit decrypted files)
sops --decrypt secret.yaml
```

### Flux Operations
```bash
# Check reconciliation status
flux get kustomizations

# Force reconciliation
flux reconcile kustomization apps --with-source
flux reconcile kustomization infrastructure --with-source

# Check HelmRelease status
flux get helmreleases -A

# View Flux logs
flux logs --follow
```

### Kubernetes Inspection
```bash
# Check all resources in a namespace
kubectl get all -n <namespace>

# Check network policies
kubectl get networkpolicies -A

# Check events for warnings
kubectl events -A --types=Warning
```

## Architecture

### GitOps Structure
FluxCD watches this repository and reconciles three independent Kustomizations defined in `clusters/staging/`:

- **`apps.yaml`** → `apps/staging/` — application workloads
- **`infrastructure.yaml`** → `infrastructure/staging/` — platform services (Cloudflare Tunnel, Renovate)
- **`monitoring.yaml`** → `monitoring/staging/` — kube-prometheus-stack

All three Kustomizations use SOPS Age decryption via a `sops-age` secret bootstrapped by `setup-cluster-k3d.sh`. Reconciliation interval is 1 minute.

### Base + Overlay Pattern
Every app follows this structure:
```
apps/
  base/<app>/        # Namespace, Deployment/HelmRelease, Service, NetworkPolicy, etc.
  staging/<app>/     # Kustomization overlay with environment-specific patches and encrypted secrets
```
`apps/staging/kustomization.yaml` lists all active apps. Adding an app = adding its overlay directory and referencing it there.

### Deployment Types
Two patterns are used depending on the app:
- **Plain Deployment** (ghostfolio, linkding): Kubernetes Deployment manifests in `apps/base/<app>/deployment.yaml`
- **HelmRelease** (homepage, kube-prometheus-stack): FluxCD `HelmRelease` + `HelmRepository` resources — Flux manages the Helm lifecycle

### Secret Management
Secrets are encrypted in Git using **SOPS + Age**. The `.sops.yaml` at repo root configures encryption to target only `data` and `stringData` fields in YAML files matching `*.yaml` or `*.yml`. The Age private key (`age.agekey`) is never committed — it must be loaded into the cluster as a secret for Flux to decrypt at reconciliation time (the setup script handles this).

### External Access
Applications are exposed externally via **Cloudflare Tunnels** (zero-trust, no open ports). The tunnel configuration is in `infrastructure/staging/cloudflare-tunnel/` — the configmap maps hostnames to internal services.

### Dependency Updates
**Renovate** runs as a CronJob inside the cluster, scanning for image and Helm chart updates and opening PRs automatically. Its configuration lives in `infrastructure/base/renovate/configmap.yaml`.

## Key Conventions

- **Namespaces**: Each app gets its own namespace, defined in `apps/base/<app>/namespace.yaml`
- **Network Policies**: All apps should have NetworkPolicy manifests restricting ingress/egress. Policies live in `apps/base/<app>/networkpolicy.yaml`
- **Rolling updates**: Deployments use `maxUnavailable: 0`, `maxSurge: 1` for zero-downtime deploys
- **Replicas**: Apps run 3 replicas for resilience
- **Encrypted secrets**: Never commit plaintext secrets; always `sops --encrypt` before committing
- **Removing an app**: Delete `apps/base/<app>/` and `apps/staging/<app>/`, and remove the entry from `apps/staging/kustomization.yaml`
