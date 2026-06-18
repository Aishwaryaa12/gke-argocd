variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
}

variable "docker_repo_name" {
  type        = string
  description = "The name of the Artifact Registry repository"
}

variable "eso_managed_secrets" {
  type        = list(string)
  description = "List of Secret Manager secret IDs that ESO should be able to access"
  default     = []
}
