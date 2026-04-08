# resource "google_compute_instance_template" "tpl" {
#   name         = "${var.name}-internal-app-template"
#   machine_type = "e2-medium"
#
#   disk {
#     source_image = "debian-cloud/debian-11"
#     auto_delete  = true
#     boot         = true
#   }
#
#   network_interface {
#     subnetwork = var.subnetwork
#   }
#
#   tags = [
#     "internal-app"
#   ]
#
#   metadata_startup_script = <<-EOT
#     #!/bin/bash
#     apt-get update && apt-get install -y apache2 netcat-openbsd
#     echo "Internal Node: $(hostname)" > /var/www/html/index.html
#     while true; do echo -e "HTTP/1.1 200 OK\n\nPort 6060: $(hostname)" | nc -l -p 6060; done &
#   EOT
# }
#
# resource "google_compute_region_instance_group_manager" "mig" {
#   name               = "${var.name}-internal-mig"
#   region             = var.region
#   base_instance_name = "web"
#   target_size        = 2
#
#   version {
#     instance_template = google_compute_instance_template.tpl.id
#   }
#
#   named_port {
#     name = "http"
#     port = 80
#   }
#
#   # stateful_disk {
#   #   device_name = "boot"
#   #   delete_rule = "ON_PERMANENT_INSTANCE_DELETION"
#   # }
#
#   named_port {
#     name = "custom"
#     port = 6060
#   }
# }

resource "google_compute_instance" "web_servers" {
  count        = 2
  name         = "${var.name}-server-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    # Link the VM to the reserved address resource
    network_ip = google_compute_address.internal_reserved_ips[count.index].address
  }

  metadata_startup_script = "apt-get update && apt-get install -y apache2"
  tags                    = ["internal-app"]
}

resource "google_compute_instance_group" "unmanaged_group" {
  name = "${var.name}-static-ip-group"
  zone = "${var.region}-a"

  instances = google_compute_instance.web_servers[*].self_link

  named_port {
    name = "http"
    port = 80
  }

  named_port {
    name = "custom"
    port = 6060
  }
}

resource "google_compute_address" "internal_reserved_ips" {
  count        = 2
  name         = "${var.name}-reserved-ip-${count.index + 1}"
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
  region       = var.region
}
