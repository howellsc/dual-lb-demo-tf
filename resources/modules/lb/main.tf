resource "google_compute_address" "lb_frontend_ip" {
  name         = "${var.lb_name}-lb-frontend-static-ip"
  subnetwork   = var.subnet_id
  address_type = "INTERNAL"
  region       = var.region
  # SHARED_LOADBALANCER_VIP allows you to use this same IP
  # for both your L4 and L7 forwarding rules.
  purpose = "SHARED_LOADBALANCER_VIP"
}

# Shared Health Check
resource "google_compute_region_health_check" "hc" {
  name   = "${var.lb_name}-internal-hc"
  region = var.region
  http_health_check {
    port = 80
  }
}


# --- L7 Internal (Apache) ---
resource "google_compute_region_backend_service" "l7_backend" {
  name                  = "${var.lb_name}-l7-backend"
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group           = var.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  health_checks = [google_compute_region_health_check.hc.id]
}

resource "google_compute_region_url_map" "l7_map" {
  name            = "${var.lb_name}-l7-int-map"
  region          = var.region
  default_service = google_compute_region_backend_service.l7_backend.id
}

resource "google_compute_region_target_http_proxy" "l7_proxy" {
  name    = "${var.lb_name}-l7-int-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.l7_map.id
}

resource "google_compute_forwarding_rule" "l7_rule" {
  name                  = "${var.lb_name}-l7-int-rule"
  region                = var.region
  ip_address            = google_compute_address.lb_frontend_ip.address # Same IP!
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.l7_proxy.id
  network               = var.vpc_id
  subnetwork            = var.subnet_id
}

# --- L4 Internal (Port 6060) ---
# We use INTERNAL_MANAGED here so it is compatible with the L7 LB
resource "google_compute_region_backend_service" "l4_backend" {
  name                  = "${var.lb_name}-l4-backend"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group           = var.instance_group
    balancing_mode  = "UTILIZATION" # Now they match!
    capacity_scaler = 1.0
  }
  health_checks = [google_compute_region_health_check.hc.id]
}

# --- L4 Forwarding Rule ---
resource "google_compute_forwarding_rule" "l4_rule" {
  name                  = "${var.lb_name}-l4-int-rule"
  region                = var.region
  ip_address            = google_compute_address.lb_frontend_ip.address # Same IP!
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "6060"
  ip_protocol           = "TCP"
  network               = var.vpc_id
  subnetwork            = var.subnet_id
  target                = google_compute_region_target_tcp_proxy.l4_proxy.id
}

resource "google_compute_region_target_tcp_proxy" "l4_proxy" {
  name            = "${var.lb_name}-l4-proxy-target"
  region          = var.region
  backend_service = google_compute_region_backend_service.l4_backend.id
}
