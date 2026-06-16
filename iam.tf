resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = "gke-node-sa"
  display_name = "GKE Node Pool Service Account"
  description  = "Least-privilege SA used by GKE worker nodes"
}

locals {
  gke_node_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader",
  ]
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset(local.gke_node_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}
