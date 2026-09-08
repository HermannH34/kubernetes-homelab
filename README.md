# Kubernetes Homelab

## Why I do that?

This repository is the single source of truth for my homelab - a self-hosted Kubernetes cluster managed entirely through GitOps.

This project serves as both a playground for learning and **experimenting with Kubernetes**, and a personal production environment to embrace independence by reducing my reliance on third-party platforms through **self-hosting**.

Through this Kubernetes journey, I want to get more involved in open source and build in public - and maybe help you take your first steps into self-hosted Kubernetes along the way

## Hardware

Expensive hardware is the biggest homelab myth. I started mine on a ThinkPad T420, and 
that's the beauty of Kubernetes - it turns whatever hardware you have into a cluster.

I then moved to Raspberry Pis for one simple reason: to actually cluster them. 
Raspberry Pis are great for learning and experimenting without breaking the bank:

- 1× Raspberry Pi 5 8GB - control plane
- 2× Raspberry Pi 5 4GB - worker nodes
  

## Software

I chose to start with the ![K3s](https://img.shields.io/badge/K3s-FFC61C?style=flat-square&logo=k3s&logoColor=black)  **K3s** Kubernetes distribution, running on a small edge machine - simpler to get started with.

However, I plan to migrate to [**Talos Linux**](https://www.talos.dev) by the end of the year. Talos is a fully secured, hardened OS designed specifically for Kubernetes - it exposes only the Kubernetes API, with no SSH, no package manager, and no shell. Pure infrastructure as code.

## Security

**Mozilla SOPS + age**

Every sensitive information is encrypted using Mozilla SOPS with an age key to handle secrets within the Kubernetes cluster.


## GitOps

![FluxCD](https://img.shields.io/badge/FluxCD-5468FF?style=flat-square&logo=flux&logoColor=white) 

**Flux CD** is the **GitOps** engine for the entire cluster. All resources are reconciled automatically via Kustomizations (see `cluster/staging/`).


## Internet Exposure

![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=flat-square&logo=cloudflare&logoColor=white) 

Apps are exposed to the internet via **Cloudflare Tunnels**. The agent establishes an outbound connection, so no ports need to be opened on the server - free and hassle-free.


## Operators

Kubernetes operators (CloudNativePG, Prometheus, etc.) are deployed via: 

| Operator              | Location                          | Notes            |
|-----------------------|-----------------------------------|------------------|
| CloudNativePG (CNPG)  | `operators/staging/database/`   | Postgres operator |
| Kube-Prometheus Stack | `monitoring/`                       | Monitoring stack  |

#### References
- CloudNativePG (CNPG) — [CloudNativePG Official Documentation](https://cloudnative-pg.io/docs/)
- Kube-Prometheus Stack — [Prometheus Operator Documentation](https://prometheus-operator.dev/docs/)



## Repository Structure

The repository is fully declarative - YAML files are the source of truth.

```
├── apps/                                   # All apps deployed. Each subdirectory is one Flux CD Application (namespace = dir name).
│   ├── base/
│   │   ├── 
│   │   ├── 
│   │   └── 
│   └── staging/
│       ├──
│       ├── 
│       └── 
├── clusters/
│   └── staging/.                              # Flux CD configuration and bootstrapping
│       ├── flux-system/
│       ├── apps.yaml
│       ├── infrastructure.yaml
│       ├── monitoring.yaml
│       └── operator.yaml
├── infrastructure/                            # 	Infrastructure configs (Cloudflare tunnels, Renovate)
│   ├── base/
│   │   ├── cloudflare-tunnel/
│   │   ├── flux-image-automation/
│   │   └── renovate/
│   └── staging/
│       ├── cloudflare-tunnel/
│       ├── flux-image-automation/
│       └── renovate/
├── monitoring/
│   ├── base/
│   │   └── kube-prometheus-stack/
│   └── staging/
│       └── kube-prometheus-stack/
├── operator/
│   ├── base/
│   │   └── database/
│   └── staging/
│       └── database/
├── .sops.yaml
├── cluster-health.sh
├── renovate.json
└── README.md                                  
```
