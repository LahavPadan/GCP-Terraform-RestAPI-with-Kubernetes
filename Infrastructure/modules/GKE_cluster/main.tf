
resource "google_container_cluster" "gke-cluster" {
  name               = "${var.type}-k8s"  # cluster name
  location          = var.region
  node_locations = var.zones
  initial_node_count = var.num_instances   # number of nodes (VMs) for the cluster

  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum = var.min_cpu_instances
      maximum = var.max_cpu_instances
    }
    resource_limits {
      resource_type = "memory"
      minimum = var.min_memory_instances
      maximum = var.max_memory_instances
    }
  }

  node_config {
    preemptible  = var.preemptible
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = ["${var.type}-k8s"]
  }
}


resource "google_compute_firewall" "firewall" {
  name    = "${var.type}-range"
  network = google_compute_network.network.name
  allow {
    protocol = "tcp"
    ports    = var.ports 
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}   

resource "google_compute_network" "network" {
  name = "${var.type}-network"
}
