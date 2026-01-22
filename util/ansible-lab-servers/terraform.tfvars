# ============================================
# Terraform Variables Configuration
# ============================================
# Update project_id with your GCP project ID before running terraform

# GCP Project Configuration
project_id = "cl-demo-sandbox"  # Replace with your actual GCP project ID
region     = "europe-north2"
zone       = "europe-north2-a"

# VPC Configuration (using existing VPC from GCP course)
vpc_name    = "cl-vpc-sandbox"
subnet_name = "cl-sub-sandbox-web-eu-nrth2-01"

# VM Instance Configuration
instance_count       = 3
instance_name_prefix = "ansible-lab-server"
machine_type         = "e2-micro"
vm_image             = "ubuntu-os-cloud/ubuntu-2204-lts"
disk_size_gb         = 20
disk_type            = "pd-standard"

# SSH Configuration
ssh_user       = "ansible"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoZHaZC1fHZ6VTdtFs5IDdrIXaRhmc/tnXB5jaw9t6c rahulwagh@Rahuls-MacBook-Pro-2.local"

# Network Tag
network_tag = "ansible-lab-server"

# Firewall Rule Name
firewall_name = "ansible-lab-allow-traffic"

# Labels
labels = {
  environment = "lab"
  managed-by  = "terraform"
  purpose     = "ansible-course"
  course      = "ansible-zero-to-expert"
}
