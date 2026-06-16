output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "Zone of the GKE cluster"
  value       = google_container_cluster.primary.location
}

output "cluster_endpoint" {
  description = "GKE API server endpoint"
  value       = "https://${google_container_cluster.primary.endpoint}"
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${var.zone} --project ${var.project_id}"
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


