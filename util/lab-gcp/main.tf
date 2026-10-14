# ============================================
# Ansible lab servers on Google Cloud
# ============================================
# By default this creates its own VPC + subnet so it works in any
# fresh project. Set create_network = false to reuse an existing one.

# ---------- Network: create ----------

resource "google_compute_network" "vpc" {
  count                   = var.create_network ? 1 : 0
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count         = var.create_network ? 1 : 0
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc[0].id
  ip_cidr_range = var.subnet_cidr
}

# ---------- Network: reuse existing ----------

data "google_compute_network" "existing_vpc" {
  count = var.create_network ? 0 : 1
  name  = var.vpc_name
}

data "google_compute_subnetwork" "existing_subnet" {
  count  = var.create_network ? 0 : 1
  name   = var.subnet_name
  region = var.region
}

locals {
  network_id   = var.create_network ? google_compute_network.vpc[0].id : data.google_compute_network.existing_vpc[0].id
  network_name = var.create_network ? google_compute_network.vpc[0].name : data.google_compute_network.existing_vpc[0].name
  subnet_id    = var.create_network ? google_compute_subnetwork.subnet[0].id : data.google_compute_subnetwork.existing_subnet[0].id
}

# ============================================
# Firewall: SSH, HTTP, ICMP
# ============================================

resource "google_compute_firewall" "ansible_lab" {
  name    = var.firewall_name
  network = local.network_name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.allowed_cidr]
  target_tags   = [var.network_tag]

  description = "Allow SSH, HTTP and ICMP traffic to Ansible lab servers"
}

# ============================================
# Lab servers
# ============================================

resource "google_compute_instance" "ansible_lab" {
  count        = var.instance_count
  name         = "${var.instance_name_prefix}-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [var.network_tag]

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }

  network_interface {
    network    = local.network_id
    subnetwork = local.subnet_id

    # External IP so you can SSH in
    access_config {
      network_tier = "STANDARD"
    }
  }

  # The "ansible" user + your key
  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  # Make sure Python exists for Ansible and set the hostname
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    apt-get update
    apt-get install -y python3 python3-apt
    INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" \
      http://metadata.google.internal/computeMetadata/v1/instance/name)
    hostnamectl set-hostname "$INSTANCE_NAME"
    echo "Ansible lab server setup complete!"
  EOF

  labels = var.labels

  allow_stopping_for_update = true

  service_account {
    scopes = ["cloud-platform"]
  }
}
