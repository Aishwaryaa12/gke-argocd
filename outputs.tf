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
