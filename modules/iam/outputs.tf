output "gke_node_sa_email" {
  value       = google_service_account.gke_nodes.email
  description = "Email of the GKE node service account"
}

output "workload_identity_provider_name" {
  value       = google_iam_workload_identity_pool_provider.github_provider.name
  description = "The Workload Identity Provider name for GitHub Actions"
}

output "github_actions_service_account_email" {
  value       = google_service_account.github_actions.email
  description = "The Service Account email for GitHub Actions to impersonate"
}

output "eso_sa_email" {
  value       = google_service_account.eso_sa.email
  description = "Email of the External Secrets Operator service account"
}
