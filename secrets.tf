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

# The actual secret version (value) can be created manually via GCP console, 
# or via terraform if we pass it as a sensitive variable. For now, we just provision the secret container.
