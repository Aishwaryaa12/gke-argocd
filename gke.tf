# ─── GKE Standard Cluster ────────────────────────────────────────────────────
resource "google_container_cluster" "primary" {
  provider = google

  project  = var.project_id
  name     = var.cluster_name
  location = var.zone # zonal cluster (cheaper than regional — no 3× control plane)

  # ── Networking ──────────────────────────────────────────────────────────────
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  # VPC-native (alias IP) — required for Network Policies, Dataplane V2, etc.
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }



  # Remove immediately — we manage node pools separately via google_container_node_pool.
  # This gives full lifecycle control (e.g., recreate without destroying the cluster).
  remove_default_node_pool = true
  initial_node_count       = 1 # required placeholder; immediately deleted

  # ── Kubernetes Version ──────────────────────────────────────────────────────
  # Using REGULAR release channel — GKE manages version selection & upgrades.
  # This avoids having to pin exact version strings which vary by region/zone.
  release_channel {
    channel = "REGULAR"
  }

  # ── Workload Identity ───────────────────────────────────────────────────────
  # Allows K8s service accounts to impersonate GCP service accounts —
  # the secure alternative to mounting SA keys into pods.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # ── Add-ons ─────────────────────────────────────────────────────────────────
  addons_config {
    # HTTP load balancing needed for GKE-managed Ingress (keep enabled)
    http_load_balancing {
      disabled = false
    }
    # Horizontal Pod Autoscaler — free, keep enabled
    horizontal_pod_autoscaling {
      disabled = false
    }
    # Network policy is handled natively by Dataplane V2 (Cilium).
    # Must be disabled when datapath_provider = ADVANCED_DATAPATH.
    network_policy_config {
      disabled = true
    }
  }

  # Dataplane V2 (Cilium) — enabled by GKE REGULAR channel by default.
  # Provides eBPF-based networking, replaces kube-proxy, handles NetworkPolicy natively.
  datapath_provider = "ADVANCED_DATAPATH"

  # ── Logging & Monitoring ────────────────────────────────────────────────────
  # Keep system components only to minimise log ingestion costs.
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # ── Maintenance ─────────────────────────────────────────────────────────────
  maintenance_policy {
    recurring_window {
      # Maintenance during off-peak hours (IST night = UTC midnight)
      start_time = "2024-01-01T18:30:00Z" # 00:00 IST
      end_time   = "2024-01-01T22:30:00Z" # 04:00 IST
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  # ── Safety ──────────────────────────────────────────────────────────────────
  # Set to false so you can cleanly terraform destroy during the free trial.
  # Flip to true before going to production.
  deletion_protection = false

  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.subnet,
  ]
}
