# Kubernetes Homelab

## Why I do that?

This repository is the single source of truth for my homelab - a self-hosted Kubernetes cluster managed entirely through GitOps.

This project serves as both a playground for learning and **experimenting with Kubernetes**, and a personal production environment to embrace independence by reducing my reliance on third-party platforms through **self-hosting**.


## Hardware

* 1 Raspberry Pi 5 8 GB: best performance for the control plane

* 2 Raspberry Pi 5 4 GB: perfect for worker nodes
  

## Software

I chose to start with the ![K3s](https://img.shields.io/badge/K3s-FFC61C?style=flat-square&logo=k3s&logoColor=black)  **K3s** Kubernetes distribution, running on a small edge machine - simpler to get started with.


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

| Folder         | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `apps/`        | User workloads. Each subdirectory is one Flux CD Application (namespace = dir name). |
| `core/`        | Flux CD configuration and bootstrapping.                                    |
| `infra/`       | Infrastructure configs: Cloudflare tunnels, Renovate.                       |
| `monitoring/`  | Monitoring stack (Kube-Prometheus Stack).                                   |
| `operators/`   | Kubernetes operators (CNPG).                                                |

