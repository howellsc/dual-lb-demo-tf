resource "google_compute_network" "vpc" {
  name                    = "${var.name}-internal-infra"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "app_subnet" {
  name          = "${var.name}-sub"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "proxy_only" {
  name          = "${var.name}-proxy-only-subnet"
  ip_cidr_range = "10.129.0.0/23"
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.vpc.id

  depends_on = [
    google_compute_network.vpc
  ]
}

# 1. Allow Google Health Checks
# This range is constant across all of Google Cloud
resource "google_compute_firewall" "allow_health_checks" {
  name          = "${var.name}-allow-health-checks"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["internal-app"] # Apply this tag to your GCE instances

  allow {
    protocol = "tcp"
    ports    = ["80", "6060"]
  }
}

# 2. Allow Traffic from the Proxy-Only Subnet
# This is where the L7 and L4 Proxy data actually originates
resource "google_compute_firewall" "allow_proxy_traffic" {
  name          = "${var.name}-allow-proxy-to-backends"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  # Use the CIDR of the REGIONAL_MANAGED_PROXY subnet you created
  source_ranges = ["10.129.0.0/23"]
  target_tags   = ["internal-app"]

  allow {
    protocol = "tcp"
    ports    = ["80", "6060"]
  }
}

# 3. Allow Client-to-LB Traffic
# This allows other VMs in your VPC to talk to the Load Balancers
resource "google_compute_firewall" "allow_internal_clients" {
  name          = "${var.name}-allow-internal-clients-to-lb"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/8"] # Adjust to your internal IP range

  allow {
    protocol = "tcp"
    ports    = ["80", "6060"]
  }
}
