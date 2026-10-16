# ============================================
# Ansible real-world project · Google Cloud
# 4 Ubuntu 22.04 VMs: lb-1, app-1, app-2, db-1
# ============================================

# Public key: explicit variable, or the repo-local infra/keys/lab.pub
locals {
  ssh_public_key = coalesce(var.ssh_public_key, trimspace(file("${path.module}/../keys/lab.pub")))
}

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.vpc_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr
}

# Public: SSH, HTTP, HTTPS to every server (only lb-1 really needs 80/443, keep it simple for the lab)
resource "google_compute_firewall" "public" {
  name    = "${var.vpc_name}-allow-public"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  allow { protocol = "icmp" }
  source_ranges = [var.allowed_cidr]
  target_tags   = ["ansible-project"]
}

# Internal: anything between the servers (app -> postgres 5432, lb -> app 8000)
resource "google_compute_firewall" "internal" {
  name    = "${var.vpc_name}-allow-internal"
  network = google_compute_network.vpc.name
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
  source_ranges = [var.subnet_cidr]
  target_tags   = ["ansible-project"]
}

resource "google_compute_instance" "server" {
  for_each     = var.servers
  name         = each.key
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["ansible-project", each.value]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config { network_tier = "STANDARD" }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${local.ssh_public_key}"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update && apt-get install -y python3 python3-apt
    hostnamectl set-hostname ${each.key}
  EOF

  labels                    = { for k, v in var.tags : k => v }
  allow_stopping_for_update = true
}

locals {
  public_ip  = { for k, i in google_compute_instance.server : k => i.network_interface[0].access_config[0].nat_ip }
  private_ip = { for k, i in google_compute_instance.server : k => i.network_interface[0].network_ip }
}
