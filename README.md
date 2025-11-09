<div align="center">

# 🏠 Production-Grade Kubernetes Homelab
*Implementing production practices in a learning environment*

*Building enterprise-level infrastructure, one commit at a time*

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

**A declarative, production-ready Kubernetes cluster managed entirely through GitOps principles**


</div>

---

## 🎯 What is this?

This is a **Kubernetes homelab cluster** implementing production-grade tools and 
practices in a pre-production environment. Managed with industry-standard DevOps 
practices, every configuration is version-controlled, every secret is encrypted, 
and every deployment is automated.

**The Goal?** To demonstrate hands-on expertise with cloud-native technologies while self-hosting useful applications and learning by doing.

---

## 🚀 The Technology Stack

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

### Automation

| Technology | Purpose | Why? |
|------------|---------|------|
| ![Renovate](https://img.shields.io/badge/Renovate-1A1F6C?style=flat-square&logo=renovatebot&logoColor=white) **Renovate** | Dependency | Automated PRs for keeping dependencies update |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
                 ┌───────────────┐
                 │   Cloudflare  │
                 │    Tunnels    │
                 └───────┬───────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│                    K3s Cluster (2 Nodes)                    │
│                                                              │
│  ┌────────────┐      ┌──────────────┐    ┌──────────────┐  │
│  │   Traefik  │◄─────┤   FluxCD     │───►│  Helm        │  │
│  │  (Ingress) │      │  (GitOps)    │    │  Releases    │  │
│  └─────┬──────┘      └──────────────┘    └──────────────┘  │
│        │                                                     │
│  ┌─────┴─────────────────────────────────────────────────┐  │
│  │               Application Workloads                   │  │
│  │                                                        │  │
│  │  📊 Homepage  │  🔖 Linkding  │  📈 Grafana          │  │
│  │                                                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Monitoring & Observability                   │  │
│  │                                                        │  │
│  │  Prometheus  ◄──►  Grafana  ◄──►  Alertmanager       │  │
│  │                                                        │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### Key Features

- **🔄 Fully GitOps-driven**: Every change goes through Git
- **🔐 Zero plaintext secrets**: All sensitive data encrypted with SOPS
- **🌐 Secure external access**: Cloudflare Tunnels for zero-trust networking
- **📊 Full observability**: Prometheus + Grafana monitoring every pod
- **🤖 Automated maintenance**: Renovate keeps dependencies up-to-date
- **📦 Declarative infrastructure**: Everything as code, reproducible anywhere

---

## 📁 Repository Structure

```
kubernetes-homelab/
│
├── 📱 apps/                        # Application definitions
│   ├── base/                       # Base Helm releases & configs
│   │   ├── homepage/               # Dashboard application
│   │   └── linkding/               # Bookmark manager
│   └── staging/                    # Environment-specific overlays
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
│   └── controllers/
│       └── base/renovate/          # Automated dependency updates
│
├── 📊 monitoring/                  # Observability stack
│   ├── configs/                    # Monitoring configurations
│   │   └── base/kube-prometheus-stack/
│   └── controllers/                # Monitoring operators
│       └── base/kube-prometheus-stack/
│
├── 🔐 age.agekey                   # Age encryption key
├── 🔒 .sops.yaml                   # SOPS configuration
└── 📝 README.md                    # You are here
```

---

## 📱 Deployed Applications

### 🏠 Homepage
**A modern, customizable application dashboard**

- Centralized portal for all services
- Resource monitoring integration
- Custom bookmarks and widgets
- Accessible via Traefik ingress

### 🔖 Linkding
**Minimalist, fast, and self-hosted bookmark manager**

- Full-text search across bookmarks
- Tag-based organization
- Archive integration
- Persistent storage with backups

### 📈 Grafana
**Beautiful metrics and monitoring dashboards**

- Real-time cluster metrics
- Pre-configured dashboards for Kubernetes
- Alert configuration and management
- Accessible via Cloudflare Tunnel

---


## 🎓 What's Next?

### Planned Improvements

### 🚀 Short-term Goals (Next 3-6 months)
- [ ] Deploy more applications
- [ ] CI/CD pipeline integration
- [ ] Implement automated Velero backups

### 🏔️ Advanced Goals (6-12 months)
- [ ] **Talos Linux**: Migrate to immutable, API-driven OS for Kubernetes
- [ ] **Bare-metal load balancing**: MetalLB or Cilium BGP


---

## 💡 Why This Matters

This homelab demonstrates **practical, production-ready skills** that translate directly to professional DevOps and SRE roles:

- **GitOps Expertise**: Modern deployment practices used by industry leaders
- **Kubernetes Proficiency**: Hands-on experience with cloud-native orchestration
- **Security Mindset**: Proper secrets management and zero-trust networking
- **Observability**: Understanding metrics, logging, and alerting
- **Automation**: Reducing toil through infrastructure as code
- **Documentation**: Clear communication of complex systems

---

<div align="center">

**Built with ❤️ and ☕ by a DevOps enthusiast**

*Every failure is a learning opportunity. Every success is documented.*

</div>