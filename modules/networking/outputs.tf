output "network_id" {
  value       = google_compute_network.vpc.id
  description = "The ID of the VPC"
}

output "subnet_id" {
  value       = google_compute_subnetwork.subnet.id
  description = "The ID of the subnetwork"
}

output "network_name" {
  value       = google_compute_network.vpc.name
  description = "The name of the VPC"
}

output "subnet_name" {
  value       = google_compute_subnetwork.subnet.name
  description = "The name of the subnetwork"
}
