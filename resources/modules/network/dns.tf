resource "google_dns_managed_zone" "private_zone" {
  name        = "${var.name}-internal-services-zone"
  dns_name    = "nwm.infra.net." # Must end with a dot
  description = "Private DNS zone for internal load balancers"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
  }
}

resource "google_dns_record_set" "lb_dns" {
  name         = "${var.name}-app.${google_dns_managed_zone.private_zone.dns_name}" # 'var.name'-app.natwest.internal.
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = 300

  # This references the static IP we reserved for the LB frontend
  rrdatas = [var.lb_ip]
}
