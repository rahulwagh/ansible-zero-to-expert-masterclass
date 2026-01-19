# ============================================
# Data Sources - Reference Existing VPC and Subnet
# ============================================
# Using VPC and Subnet from GCP course (Chapter 2/5)

data "google_compute_network" "vpc" {
  name = var.vpc_name
}

data "google_compute_subnetwork" "subnet" {
  name   = var.subnet_name
  region = var.region
}

# ============================================
# Firewall Rule
# ============================================

# Allow SSH, HTTP and ICMP traffic to Ansible lab servers
resource "google_compute_firewall" "ansible_lab" {
  name    = var.firewall_name
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.network_tag]

  description = "Allow SSH, HTTP and ICMP traffic to Ansible lab servers"
}

# ============================================
# Ansible Lab VM Instances
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
    network    = data.google_compute_network.vpc.id
    subnetwork = data.google_compute_subnetwork.subnet.id

    # Assign external IP for SSH access
    access_config {
      network_tier = "STANDARD"
    }
  }

  # SSH key metadata
  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  # Startup script to prepare the instance for Ansible
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # Update package list
    apt-get update

    # Install Python (required for Ansible)
    apt-get install -y python3 python3-pip

    # Create symbolic link for python
    ln -sf /usr/bin/python3 /usr/bin/python

    # Set hostname based on instance name
    INSTANCE_NAME=$(curl -H "Metadata-Flavor: Google" \
      http://metadata.google.internal/computeMetadata/v1/instance/name)
    hostnamectl set-hostname $INSTANCE_NAME

    echo "Ansible lab server setup complete!"
  EOF

  labels = var.labels

  # Allow stopping for update
  allow_stopping_for_update = true

  # Service account with minimal permissions
  service_account {
    scopes = ["cloud-platform"]
  }
}
