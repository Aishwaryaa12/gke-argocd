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
