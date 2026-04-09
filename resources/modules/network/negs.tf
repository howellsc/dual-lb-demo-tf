# 1. NEG for L7 (Port 80)
resource "google_compute_network_endpoint_group" "neg_l7" {
  name                  = "${var.name}-neg-l7-http"
  network               = google_compute_network.vpc.id
  subnetwork            = google_compute_subnetwork.app_subnet.id
  zone                  = var.zone
  network_endpoint_type = "GCE_VM_IP_PORT" # Specifies IP + Port 80
}

# 2. NEG for L4 (Port 6060)
resource "google_compute_network_endpoint_group" "neg_l4" {
  name                  = "${var.name}-neg-l4-data"
  network               = google_compute_network.vpc.id
  subnetwork            = google_compute_subnetwork.app_subnet.id
  zone                  = var.zone
  network_endpoint_type = "GCE_VM_IP" # Specifies IP only (Passthrough)
}

# 3. Attach the  VMs to BOTH NEGs
resource "google_compute_network_endpoint" "endpoints_l7" {
  for_each               = var.instance_summary
  network_endpoint_group = google_compute_network_endpoint_group.neg_l7.name
  instance               = each.key   # The Name (e.g., "server-1")
  ip_address             = each.value # The Reserved IP (e.g., "10.0.1.10")
  port                   = 80
  zone                   = var.zone
}

resource "google_compute_network_endpoint" "endpoints_l4" {
  for_each               = var.instance_summary
  network_endpoint_group = google_compute_network_endpoint_group.neg_l4.name
  instance               = each.key   # The Name (e.g., "server-1")
  ip_address             = each.value # The Reserved IP (e.g., "10.0.1.10")
  # No port specified here for GCE_VM_IP type
  zone = var.zone
}
