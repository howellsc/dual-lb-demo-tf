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
