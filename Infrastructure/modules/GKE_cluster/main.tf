# -------------------------------------------------------------*
# var.project_id, var.num_instances, var.clustername (default = node-demo-k8s), var.zone, var.preemptible
# -------------------------------------------------------------*
# This will created the Kubernetes cluster and nodes in GCP
resource "google_container_cluster" "primary" {
  name               = "node-demo-k8s"  # cluster name
   location          = "us-central1-c"
  initial_node_count = var.num_instances           # number of node (VMs) for the cluster
  # Google recommends custom service accounts that have cloud-platform 
  # scope and permissions granted via IAM Roles.
  # for this demo, we'll have no auth set up
  # master_auth: The aut information for accessing the Kubernetes master.
  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  # let's now configure kubectl to talk to the cluster
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.clustername} --zone ${var.zone} --project ${var.project_id}"
  }
  node_config {
    preemptible  = var.preemptible
    machine_type = "e2-micro"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = ["node-demo-k8s"]
  }
  timeouts {
    # time out after 45 min if the Kubernetes cluster creation is still not finish
    create = "45m" 
    update = "60m"
  }
}
# -------------------------------------------------------------*
# Next, we create firewall rule to allow access to application
# note: in our deploy.yml we set and know that
# The range of valid ports in kubernetes is 30000-32767
# -------------------------------------------------------------*
resource "google_compute_firewall" "nodeports" {
  name    = "node-port-range"
  network = "default"
  allow {
    protocol = "tcp"
    # valid ports in kubernetes is 30000-32767
    # port 80 for HTTP and 443 for HTTPS
    # port 22 for SSH into the node and pod if needed
    ports    = ["30000-32767", "80", "443", "8080", "22"]  
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
} 