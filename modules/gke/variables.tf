variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "zone" {
  type        = string
  description = "The GCP zone"
}

variable "cluster_name" {
  type        = string
  description = "The name of the GKE cluster"
}

variable "network_id" {
  type        = string
  description = "The ID of the VPC network"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnetwork"
}

variable "node_pool_name" {
  type        = string
  description = "The name of the GKE node pool"
}

variable "node_count" {
  type        = number
  description = "The initial number of nodes"
}

variable "node_machine_type" {
  type        = string
  description = "The machine type for GKE nodes"
}

variable "node_disk_size_gb" {
  type        = number
  description = "The disk size for GKE nodes in GB"
}

variable "node_disk_type" {
  type        = string
  description = "The disk type for GKE nodes"
}

variable "gke_node_sa_email" {
  type        = string
  description = "The email of the GKE node service account"
}

variable "master_authorized_networks" {
  type        = string
  description = "The CIDR block for master authorized networks"
}
