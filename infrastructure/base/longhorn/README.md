# Longhorn — Distributed Block Storage

[Longhorn](https://longhorn.io) is a cloud-native distributed block storage system
for Kubernetes. It replaces the default K3s `local-path` StorageClass with a
replicated, snapshot-capable storage backend.

## Why Longhorn?

| Feature | local-path | Longhorn |
|---------|-----------|---------|
| Volume replication | No | Yes (2 replicas) |
| Snapshots | No | Yes |
| S3 backups | No | Yes (optional) |
| Management UI | No | Yes |
| Default StorageClass | Yes | Yes (replaces) |

## Files

| File | Description |
|------|-------------|
| `namespace.yaml` | Creates the `longhorn-system` namespace |
| `repository.yaml` | FluxCD HelmRepository pointing to `https://charts.longhorn.io` |
| `release.yaml` | FluxCD HelmRelease deploying Longhorn v1.x |
| `kustomization.yaml` | Kustomize entry point listing all resources |

## Configuration

Key settings in `release.yaml`:

| Setting | Value | Description |
|---------|-------|-------------|
| `defaultReplicaCount` | `2` | Two replicas per volume |
| `defaultDataPath` | `/var/lib/longhorn` | Host path for volume data |
| `persistence.defaultClass` | `true` | Longhorn becomes the default StorageClass |
| `persistence.defaultFsType` | `ext4` | Default filesystem |
| `ingress.enabled` | `false` | UI exposed via Cloudflare Tunnel instead |

## UI Access

The Longhorn UI is accessible at `https://longhorn.quickyrails.com` via Cloudflare Tunnel.
The tunnel route is configured in `infrastructure/staging/cloudflare-tunnel/configmap.yaml`.

## Staging overlay

The staging overlay is at `infrastructure/staging/longhorn/`.
It is registered as a Flux Kustomization in `clusters/staging/infrastructure.yaml`.
