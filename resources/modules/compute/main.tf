resource "google_compute_instance_template" "tpl" {
  name         = "${var.name}-internal-app-template"
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  tags = [
    "internal-app"
  ]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update && apt-get install -y apache2 netcat-openbsd
    echo "Internal Node: $(hostname)" > /var/www/html/index.html
    while true; do echo -e "HTTP/1.1 200 OK\n\nPort 6060: $(hostname)" | nc -l -p 6060; done &
  EOT
}

resource "google_compute_region_instance_group_manager" "mig" {
  name               = "${var.name}-internal-mig"
  region             = var.region
  base_instance_name = "web"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.tpl.id
  }

  named_port {
    name = "http"
    port = 80
  }

  named_port {
    name = "custom"
    port = 6060
  }
}
