<div align="center">

# 🏠 Kubernetes Homelab
*Implementing production practices in a learning environment*

> [!WARNING]
> **⚠️ Work in Progress**: This homelab is under active development. Configurations may change frequently and some features may be incomplete or experimental.

[![K3s](https://img.shields.io/badge/k3s-FFC61C?style=for-the-badge&logo=k3s&logoColor=black)](https://k3s.io/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![FluxCD](https://img.shields.io/badge/FluxCD-5468FF?style=for-the-badge&logo=flux&logoColor=white)](https://fluxcd.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)](https://helm.sh/)

[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)
[![SOPS](https://img.shields.io/badge/SOPS-000000?style=for-the-badge&logo=mozilla&logoColor=white)](https://github.com/getsops/sops)
[![Renovate](https://img.shields.io/badge/Renovate-1A1F6C?style=for-the-badge&logo=renovatebot&logoColor=white)](https://www.mend.io/renovate/)

[![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)](https://www.cloudflare.com/)
[![Traefik](https://img.shields.io/badge/Traefik-24A1C1?style=for-the-badge&logo=traefikproxy&logoColor=white)](https://traefik.io/)
[![GitOps](https://img.shields.io/badge/GitOps-100%25-success?style=for-the-badge)](https://www.gitops.tech/)

---

**A declarative, semi-production Kubernetes cluster managed entirely through GitOps principles**


</div>

---

## 🎯 What is this?

This is a **Kubernetes homelab cluster** implementing production-grade tools and 
practices in a pre-production environment. Managed with industry-standard DevOps 
practices, every configuration is version-controlled, every secret is encrypted, 
and every deployment is automated.

**The Goal?** To demonstrate hands-on expertise with cloud-native technologies while self-hosting useful applications and learning by doing.

## 🛤️ The Journey

This homelab started with **K3d** for local development, then moved to **VPS servers** (4-core, 8GB RAM) for a more realistic setup. Currently hosted in the **bare metal Cloud** while I'm relocating to Canada 🇨🇦, but the plan is to eventually run it on **Raspberry Pi hardware** once settled—because there's something special about managing physical infrastructure.


---

## 🚀 The Tech Stack

### Core Infrastructure

| Technology | Purpose | Why? |
|------------|---------|------|
| ![K3s](https://img.shields.io/badge/K3s-FFC61C?style=flat-square&logo=k3s&logoColor=black) **K3s** | Lightweight Kubernetes | Production-ready Kubernetes that runs on minimal resources |
| ![FluxCD](https://img.shields.io/badge/FluxCD-5468FF?style=flat-square&logo=flux&logoColor=white) **FluxCD** | GitOps Operator | Automatically syncs cluster state with Git repository |
| ![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat-square&logo=helm&logoColor=white) **Helm** | Package Manager | Standardized application deployments with templating |

### Security & Secrets

| Technology | Purpose | Why? |
|------------|---------|------|
| ![SOPS](https://img.shields.io/badge/SOPS-000000?style=flat-square&logo=mozilla&logoColor=white) **SOPS** | Secret Encryption | Encrypt secrets at rest in Git |

### Networking & Access

| Technology | Purpose | Why? |
|------------|---------|------|
| ![Traefik](https://img.shields.io/badge/Traefik-24A1C1?style=flat-square&logo=traefikproxy&logoColor=white) **Traefik** | Ingress Controller | Dynamic routing and automatic SSL |
| ![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=flat-square&logo=cloudflare&logoColor=white) **Cloudflare Tunnels** | Secure External | Zero-trust network access without opening ports |

### Observability

| Technology | Purpose | Why? |
|------------|---------|------|
| ![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat-square&logo=prometheus&logoColor=white) **Prometheus** | Metrics Collection | Industry-standard monitoring system |
| ![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat-square&logo=grafana&logoColor=white) **Grafana** | Visualization | Beautiful dashboards for cluster metrics |

### Automatic upgrades

| Technology | Purpose | Why? |
|------------|---------|------|
| ![Renovate](https://img.shields.io/badge/Renovate-1A1F6C?style=flat-square&logo=renovatebot&logoColor=white) **Renovate** | Dependency | Automated PRs for keeping dependencies update |


---

## 📁 Repository Structure

```
kubernetes-homelab/
│
├── 📱 apps/                        # Application definitions
│   ├── base/                       # Base manifests (reusable)
│   │   ├── ghostfolio/             # Investment portfolio tracker
│   │   ├── homepage/               # Dashboard application
│   │   └── linkding/               # Bookmark manager
│   └── staging/                    # Environment-specific overlays & secrets
│       ├── ghostfolio/
│       ├── homepage/
│       └── linkding/
│
├── 🎛️ clusters/                    # Cluster configurations
│   └── staging/
│       ├── flux-system/            # FluxCD bootstrap
│       ├── apps.yaml               # App reconciliation
│       ├── infrastructure.yaml     # Infrastructure reconciliation
│       └── monitoring.yaml         # Monitoring reconciliation
│
├── 🔧 infrastructure/              # Platform services
│   ├── base/                       # Base manifests
│   │   ├── cloudflare-tunnel/      # Secure external access
│   │   └── renovate/               # Automated dependency updates
│   └── staging/                    # Environment secrets & configs
│       ├── cloudflare-tunnel/
│       └── renovate/
│
├── 📊 monitoring/                  # Observability stack
│   ├── base/kube-prometheus-stack/ # Prometheus + Grafana
│   └── staging/kube-prometheus-stack/
│
├── 🔐 age.agekey                   # Age encryption key
├── 🔒 .sops.yaml                   # SOPS configuration
└── 📝 README.md                    # You are here
```

---

## 📱 Deployed Applications

### 💰 Ghostfolio
**Open-source wealth management and portfolio tracker**

- Track stocks, ETFs, cryptocurrencies, and more
- Performance analytics and dividends tracking
- Multi-currency support
- PostgreSQL + Redis backend for reliability

### 🔖 Linkding
**Minimalist, fast, and self-hosted bookmark manager**

- Full-text search across bookmarks
- Tag-based organization
- Archive integration
- Persistent storage with backups


---


## 🎓 What's Next?

### Planned Improvements

### 🚀 Short-term Goals 
- [ ] set Network Policies AND request/limits for the DB 
- [ ] add Readiness/liveness for the  apps, set Request & limits for the apps
- [ ] Create a deployment template for my NextJS personal apps
- [ ] Implement automated Longhorn Storage and Backup
- [ ] Infrastructure as Code for the entire setup

### 🏔️ Advanced Goals (6-12 months)
- [ ] Migrate FluxCD to ArgoCD with the help of AI Agents (for purpose testing) 
- [ ]  Deploy self hosted open source runners
- [ ] Setup CloudNativePG
- [ ] **AI model**: Deploy and manage AI models on kubernetes with cheap GPU hardware


