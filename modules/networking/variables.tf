variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "network_name" {
  type        = string
  description = "The name of the VPC network"
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnetwork"
}

variable "region" {
  type        = string
  description = "The GCP region for the subnetwork"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR range for the subnetwork"
}

variable "pods_cidr" {
  type        = string
  description = "CIDR range for GKE pods"
}

variable "services_cidr" {
  type        = string
  description = "CIDR range for GKE services"
}
