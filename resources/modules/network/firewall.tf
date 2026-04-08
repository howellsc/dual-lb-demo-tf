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
    ports    = ["80"]
  }
}

# 2. Allow Traffic from the Proxy-Only Subnet
# This is where the L7 and L4 Proxy data actually originates
resource "google_compute_firewall" "allow_proxy_traffic" {
  name      = "${var.name}-allow-proxy-to-backends"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  # Use the CIDR of the REGIONAL_MANAGED_PROXY subnet you created
  source_ranges = ["10.129.0.0/23"]
  target_tags   = ["internal-app"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_l4_client_traffic" {
  name    = "${var.name}-allow-l4-clients"
  network = google_compute_network.vpc.id
  # Allow traffic from within your VPC (e.g., 10.0.0.0/8)
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["internal-app"]

  allow {
    protocol = "tcp"
    ports    = ["6060"]
  }
}

# 3. Allow Client-to-LB Traffic
# This allows other VMs in your VPC to talk to the Load Balancers
resource "google_compute_firewall" "allow_internal_clients" {
  name          = "${var.name}-allow-internal-clients-to-lb"
  network       = google_compute_network.vpc.id
  direction     = "EGRESS"
  source_ranges = ["0.0.0.0/0"]

  target_tags = ["client-vm"]

  allow {
    protocol = "tcp"
    ports    = ["80", "6060"]
  }
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]

  source_ranges = ["0.0.0.0/0"]
}
