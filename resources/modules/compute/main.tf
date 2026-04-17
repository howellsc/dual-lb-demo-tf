resource "google_compute_instance_group" "web_servers_instance_group" {
  name      = "${var.name}-instance-group"
  instances = google_compute_instance.web_servers[*].id

  named_port {
    name = "http"
    port = 90
  }
}

resource "google_compute_instance" "web_servers" {
  count        = var.compute_instances
  name         = "${var.name}-server-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-9"
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    # Link the VM to the reserved address resource
    network_ip = google_compute_address.internal_reserved_ips[count.index].address
  }

  metadata_startup_script = file("${path.module}/scripts/startup.sh")
  tags                    = ["internal-app"]
}

resource "google_compute_instance" "test-server" {
  name         = "${var.name}-test-server"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-9"
    }
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  metadata_startup_script = "firewall-cmd --permanent --add-service=ssh && firewall-cmd --reload"

  tags = ["ssh", "client-vm"]
}

resource "google_compute_address" "internal_reserved_ips" {
  count        = var.compute_instances
  name         = "${var.name}-reserved-ip-${count.index + 1}"
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
  region       = var.region
}
