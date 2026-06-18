variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "GCP zone for the GKE cluster"
  type        = string
  default     = "asia-south1-a"
}

variable "network_name" {
  description = "Name of the custom VPC network"
  type        = string
  default     = "gke-vpc"
}

variable "subnet_name" {
  description = "Name of the primary subnet"
  type        = string
  default     = "gke-subnet"
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods"
  type        = string
  default     = "10.48.0.0/14"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services"
  type        = string
  default     = "10.52.0.0/20"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "gke-argocd-cluster"
}

variable "node_pool_name" {
  description = "Name of the primary node pool"
  type        = string
  default     = "primary-pool"
}

variable "node_machine_type" {
  description = "Machine type for cluster nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "node_disk_size_gb" {
  description = "Boot disk size per node in GB"
  type        = number
  default     = 50
}

variable "node_disk_type" {
  description = "Boot disk type per node"
  type        = string
  default     = "pd-standard"
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of the argo-cd Helm chart"
  type        = string
  default     = "9.5.21"
}

variable "argocd_release_name" {
  description = "Helm release name for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt expiry notifications"
  type        = string
}
