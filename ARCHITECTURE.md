# Architecture Overview

This document outlines the high-level architecture of the GKE GitOps environment.

```mermaid
graph TD
    %% Define User / External Access
    User([User / Browser])
    Developer([Developer])
    GitHub["GitHub Repo <br/>(Aishwaryaa12/gke-argocd)"]

    subgraph "Google Cloud Platform (GCP)"
        %% Cloud Load Balancing & Networking
        GCLB["Cloud Load Balancer <br/>(Gateway API)"]
        SecretManager[GCP Secret Manager]
        ArtifactRegistry[Artifact Registry]
        WIF[Workload Identity Federation]

        subgraph "GKE Cluster (Dataplane V2)"
            %% Ingress / Networking
            GatewayClass(gke-l7-gxlb GatewayClass)

            subgraph "Namespace: argocd"
                ArgoCD[ArgoCD Server]
            end

            subgraph "Namespace: monitoring"
                Prometheus[Prometheus]
                Grafana[Grafana]
                AlertManager[Alertmanager]
            end

            subgraph "Namespace: external-secrets"
                ESO[External Secrets Operator]
            end

            subgraph "Namespace: cert-manager"
                CertManager[cert-manager]
            end

            subgraph "Namespace: kyverno"
                Kyverno[Kyverno Policy Engine]
            end
            
            subgraph "Namespace: cnpg-system"
                CNPG[CloudNativePG Operator]
            end

            %% Applications Layer
            subgraph "Workload Namespaces"
                Apps[User Applications]
                K8sSecret[K8s Secret]
            end
        end
    end

    %% Flow: External Traffic
    User -->|HTTPS| GCLB
    GCLB -->|Routes| GatewayClass
    GatewayClass --> Apps
    GatewayClass --> ArgoCD
    GatewayClass --> Grafana

    %% Flow: GitOps
    ArgoCD -->|Pulls Manifests| GitHub
    ArgoCD -->|Syncs| Apps
    ArgoCD -->|Syncs| Prometheus
    ArgoCD -->|Syncs| ESO
    ArgoCD -->|Syncs| Kyverno

    %% Flow: CI/CD
    Developer -->|Pushes Code| GitHub
    GitHub -->|Triggers CI| GHA[GitHub Actions]
    GHA -->|1. Build & Scan| GHA
    GHA -->|2. WIF Auth| WIF
    WIF -->|3. Sign & Push Image| ArtifactRegistry
    GHA -->|4. Update GitOps Tag| GitHub

    %% Flow: Secrets
    ESO -->|Reads via Workload Identity| SecretManager
    ESO -->|Creates| K8sSecret
    K8sSecret --> Apps
    
    %% Flow: Policies
    Kyverno -->|Validates/Mutates| Apps
```

## Key Components

1. **Infrastructure as Code (Terraform)**: Provisions the GKE cluster (Dataplane V2), VPC network, IAM roles, Workload Identity, Secret Manager, and Artifact Registry.
2. **GitOps (ArgoCD)**: Continuously syncs Kubernetes manifests from the `gitops/apps` directory, ensuring the cluster state matches Git.
3. **Ingress (Gateway API)**: Replaces traditional ingress controllers by integrating directly with GCP Cloud Load Balancing for routing external traffic.
4. **Secrets Management (External Secrets Operator)**: Syncs sensitive data from GCP Secret Manager into native Kubernetes Secrets using Workload Identity (no service account keys).
5. **Observability (kube-prometheus-stack)**: Provides cluster metrics, alerting, and dashboards via Prometheus and Grafana.
6. **Policy Enforcement (Kyverno)**: Enforces security best practices such as disallowing the `:latest` image tag, requiring resource limits, and preventing privilege escalation.
7. **Database Operations (CloudNativePG)**: Manages PostgreSQL clusters natively within Kubernetes, handling replication, failover, and backups.
