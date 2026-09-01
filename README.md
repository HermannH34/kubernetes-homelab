# Kubernetes GitOps Monorepo

## Overview

This repository is the **single source of truth** for my homelab – a self-hosted Kubernetes cluster managed entirely through **GitOps**.

The core driver behind this project is simple: **reducing my dependency on third-party platforms**.

Today, a handful of companies control a massive share of our digital lives – managing our data, identities, and infrastructure under their own rules. Moving away from this model isn't ideological for me; it's practical. The fewer single points of failure I rely on, the more control I retain over my own work.

A concrete example of this is my transition away from GitHub. My source code now lives on **[Forgejo](https://forgejo.org)**, a self-hosted Git server running directly inside this cluster. This ensures my data and history remain entirely mine. The catalyst for this move was simple: in 2025, GitHub announced pricing changes for self-hosted Actions runners – the exact type of unpredictable platform risk you can't plan for.

While I still mirror my repositories to GitHub to stay connected to the community, I am no longer dependent on it.

The project is aligned with [The Twelve-Factor App](https://12factor.net/) methodology.
---


## Core Technology Stack

This project leverages the following technologies to ensure scalability, security, and automation:


| Technology | Purpose | Why? |
|------------|---------|------|
| ![K3s](https://img.shields.io/badge/K3s-FFC61C?style=flat-square&logo=k3s&logoColor=black) | Lightweight Kubernetes | Production-ready Kubernetes that runs on minimal resources |
| ![FluxCD](https://img.shields.io/badge/FluxCD-5468FF?style=flat-square&logo=flux&logoColor=white)  | GitOps Operator | Automatically syncs cluster state with Git repository |
| ![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat-square&logo=helm&logoColor=white) | Package Manager | Standardized application deployments with templating |

### Security & Secrets

| Technology | Purpose | Why? |
|------------|---------|------|
| ![SOPS](https://img.shields.io/badge/SOPS-000000?style=flat-square&logo=mozilla&logoColor=white) | Secret Encryption | Encrypt secrets at rest in Git |

### Networking & Access

| Technology | Purpose | Why? |
|------------|---------|------|
| ![Traefik](https://img.shields.io/badge/Traefik-24A1C1?style=flat-square&logo=traefikproxy&logoColor=white) | Ingress Controller | Dynamic routing and automatic SSL |
| ![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=flat-square&logo=cloudflare&logoColor=white) | Secure External | Zero-trust network access without opening ports |

### Observability

| Technology | Purpose | Why? |
|------------|---------|------|
| ![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat-square&logo=prometheus&logoColor=white) | Metrics Collection | Industry-standard monitoring system |
| ![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat-square&logo=grafana&logoColor=white) | Visualization | Beautiful dashboards for cluster metrics |

### Automatic upgrades

| Technology | Purpose | Why? |
|------------|---------|------|
| ![Renovate](https://img.shields.io/badge/Renovate-1A1F6C?style=flat-square&logo=renovatebot&logoColor=white)| Dependency | Automated PRs for keeping dependencies update |

### Database

| Technology | Purpose | Why? |
|------------|---------|------|
| ![CloudNativePG](https://img.shields.io/badge/CloudNativePG-326CE5?style=flat-square&logo=postgresql&logoColor=white) | Database + Backup | PostgreSQL backup via **Barman** to S3 object store with periodic automatic snapshots |


---

## Repository Structure

The repository is structured in conformity with the [monorepo](https://fluxcd.io/flux/guides/repository-structure/) methodology.
```
├── apps/
│   ├── base/
│   │   ├── 
│   │   ├── 
│   │   └── 
│   └── staging/
│       ├──
│       ├── 
│       └── 
├── clusters/
│   └── staging/
│       ├── flux-system/
│       ├── apps.yaml
│       ├── infrastructure.yaml
│       ├── monitoring.yaml
│       └── operator.yaml
├── infrastructure/
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
└── README.md                                    # Matches all the YAML files in the repository. 
```
