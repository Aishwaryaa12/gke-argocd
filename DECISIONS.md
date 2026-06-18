# Architecture Decision Records (ADRs)

## 1. Gateway API vs Ingress
**Decision:** Use Kubernetes Gateway API (GKE L7 Global External Load Balancer) over traditional Ingress (e.g., NGINX Ingress).
**Rationale:** Gateway API is the future of Kubernetes networking, offering a more expressive, role-oriented model. It natively integrates with GCP Cloud Load Balancing, allowing us to leverage GCP's managed certificates, Cloud Armor, and global anycast IPs seamlessly without deploying and managing third-party ingress controllers.

## 2. CloudNativePG (CNPG) over Managed Cloud SQL
**Decision:** Deploy PostgreSQL using the CloudNativePG operator instead of using a managed service like GCP Cloud SQL.
**Rationale:** Given the current cost constraints and scale requirements, running CNPG directly in the cluster keeps the cloud bill lower while still providing enterprise-grade features (streaming replication, automated failover, automated point-in-time recovery backups to GCS). This also avoids external VPC peering complexities.

## 3. Dataplane V2 (Cilium)
**Decision:** Enable GKE Dataplane V2 instead of the standard kube-proxy.
**Rationale:** Dataplane V2 is based on eBPF (Cilium) and provides significantly higher performance, advanced NetworkPolicies enforcement out-of-the-box, and deeper network visibility without the overhead of iptables. It is the recommended standard for modern GKE clusters.

## 4. External Secrets Operator (ESO) vs Sealed Secrets
**Decision:** Use External Secrets Operator integrated with GCP Secret Manager via Workload Identity.
**Rationale:** ESO natively syncs secrets from an external, centralized, and audited vault (GCP Secret Manager) into Kubernetes native Secrets. This avoids checking encrypted secrets into Git (as with Sealed Secrets) and provides a clear separation of concerns, where Terraform provisions the GCP secrets and IAM, and GitOps handles the sync.

## 5. ApplicationSet Path Convention
**Decision:** Adopt a strict `gitops/workloads/helm/<namespace>/<app>` structure for all Helm-based workloads.
**Rationale:** We are using an ArgoCD ApplicationSet with a Git Directory Generator targeting `gitops/workloads/helm/*/*`. The ApplicationSet derives the target namespace using the `{{path[3]}}` variable. Because `path[3]` resolves to the 4th segment in the directory tree (which corresponds to `<namespace>`), **this directory depth must be strictly maintained**. If an app directory is moved one level up or down, the namespace mapping will fail or map incorrectly, breaking the deployments silently.
