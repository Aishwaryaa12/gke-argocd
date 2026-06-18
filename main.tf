module "networking" {
  source = "./modules/networking"

  project_id    = var.project_id
  network_name  = var.network_name
  subnet_name   = var.subnet_name
  region        = var.region
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}

module "iam" {
  source = "./modules/iam"

  project_id       = var.project_id
  region           = var.region
  docker_repo_name = google_artifact_registry_repository.docker_repo.name
}

module "gke" {
  source = "./modules/gke"

  project_id        = var.project_id
  zone              = var.zone
  cluster_name      = var.cluster_name
  network_id        = module.networking.network_id
  subnet_id         = module.networking.subnet_id
  node_pool_name    = var.node_pool_name
  node_count        = var.node_count
  node_machine_type = var.node_machine_type
  node_disk_size_gb = var.node_disk_size_gb
  node_disk_type    = var.node_disk_type
  gke_node_sa_email = module.iam.gke_node_sa_email
}

moved {
  from = google_compute_network.vpc
  to   = module.networking.google_compute_network.vpc
}

moved {
  from = google_compute_subnetwork.subnet
  to   = module.networking.google_compute_subnetwork.subnet
}

moved {
  from = google_compute_firewall.allow_internal
  to   = module.networking.google_compute_firewall.allow_internal
}

moved {
  from = google_compute_firewall.allow_gke_control_plane
  to   = module.networking.google_compute_firewall.allow_gke_control_plane
}

moved {
  from = google_compute_firewall.allow_health_checks
  to   = module.networking.google_compute_firewall.allow_health_checks
}

moved {
  from = google_container_cluster.primary
  to   = module.gke.google_container_cluster.primary
}

moved {
  from = google_container_node_pool.primary
  to   = module.gke.google_container_node_pool.primary
}

moved {
  from = google_service_account.gke_nodes
  to   = module.iam.google_service_account.gke_nodes
}

moved {
  from = google_project_iam_member.gke_node_roles
  to   = module.iam.google_project_iam_member.gke_node_roles
}

moved {
  from = google_project_service.iamcredentials
  to   = module.iam.google_project_service.iamcredentials
}

moved {
  from = google_service_account.github_actions
  to   = module.iam.google_service_account.github_actions
}

moved {
  from = google_artifact_registry_repository_iam_member.github_actions_writer
  to   = module.iam.google_artifact_registry_repository_iam_member.github_actions_writer
}

moved {
  from = google_iam_workload_identity_pool.github_pool
  to   = module.iam.google_iam_workload_identity_pool.github_pool
}

moved {
  from = google_iam_workload_identity_pool_provider.github_provider
  to   = module.iam.google_iam_workload_identity_pool_provider.github_provider
}

moved {
  from = google_service_account_iam_member.workload_identity_impersonation
  to   = module.iam.google_service_account_iam_member.workload_identity_impersonation
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "env"                          = "dev"
    }
  }

  depends_on = [module.gke]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.4.4"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false

  set {
    name  = "controller.replicas"
    value = "1"
  }

  set {
    name  = "server.replicas"
    value = "1"
  }

  set {
    name  = "repoServer.replicas"
    value = "1"
  }

  set {
    name  = "applicationSet.replicas"
    value = "1"
  }

  set {
    name  = "notifications.enabled"
    value = "false"
  }


  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  set {
    name  = "server.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "512Mi"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  depends_on = [
    kubernetes_namespace.argocd,
    module.gke,
  ]
}

resource "kubernetes_manifest" "argocd_root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root-apps"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/Aishwaryaa12/gke-argocd.git"
        targetRevision = "HEAD"
        path           = "gitops/apps"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace.argocd.metadata[0].name
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd
  ]
}

resource "google_project_service" "secretmanager" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "immich_db_password" {
  secret_id = "immich-db-password"

  replication {
    auto {}
  }
}

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "cluster_location" {
  description = "Zone of the GKE cluster"
  value       = module.gke.cluster_location
}

output "cluster_endpoint" {
  description = "GKE API server endpoint"
  value       = "https://${module.gke.cluster_endpoint}"
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --zone ${var.zone} --project ${var.project_id}"
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_admin_password_command" {
  description = "Command to retrieve the initial ArgoCD admin password"
  value       = "kubectl get secret argocd-initial-admin-secret -n ${var.argocd_namespace} -o jsonpath='{.data.password}' | base64 -d && echo"
}

output "argocd_loadbalancer_ip_command" {
  description = "Command to retrieve the ArgoCD LoadBalancer external IP"
  value       = "kubectl get svc argocd-server -n ${var.argocd_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
}

output "github_actions_service_account_email" {
  description = "The Service Account email for GitHub Actions to impersonate"
  value       = module.iam.github_actions_service_account_email
}

output "workload_identity_provider_name" {
  description = "The Workload Identity Provider name for GitHub Actions"
  value       = module.iam.workload_identity_provider_name
}

output "eso_sa_email" {
  description = "The External Secrets Operator Service Account email"
  value       = module.iam.eso_sa_email
}
