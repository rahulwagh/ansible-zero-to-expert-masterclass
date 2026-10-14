# ============================================
# Project
# ============================================

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region. e2-micro is free-tier eligible only in us-west1, us-central1 and us-east1."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone (must be inside var.region)"
  type        = string
  default     = "us-central1-a"
}

# ============================================
# Network
# ============================================

variable "create_network" {
  description = "Create a new VPC + subnet (true) or reuse an existing one named below (false)"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "VPC network name (created or existing)"
  type        = string
  default     = "ansible-lab-vpc"
}

variable "subnet_name" {
  description = "Subnet name (created or existing)"
  type        = string
  default     = "ansible-lab-subnet"
}

variable "subnet_cidr" {
  description = "CIDR for the subnet when create_network = true"
  type        = string
  default     = "10.100.0.0/24"
}

variable "allowed_cidr" {
  description = "Source range allowed to reach SSH/HTTP. Narrow to <your-ip>/32 if you can."
  type        = string
  default     = "0.0.0.0/0"
}

# ============================================
# VM instances
# ============================================

variable "instance_count" {
  description = "Number of lab servers"
  type        = number
  default     = 3
}

variable "instance_name_prefix" {
  description = "Prefix for the server names"
  type        = string
  default     = "ansible-lab-server"
}

variable "machine_type" {
  description = "Machine type (e2-micro is in the always-free tier, one per account)"
  type        = string
  default     = "e2-micro"
}

variable "vm_image" {
  description = "Boot disk image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

# ============================================
# SSH
# ============================================

variable "ssh_user" {
  description = "User that Ansible connects as"
  type        = string
  default     = "ansible"
}

variable "ssh_public_key" {
  description = "Contents of your SSH public key, e.g. file(\"~/.ssh/ansible-lab.pub\")"
  type        = string
}

variable "ssh_private_key_file" {
  description = "Path to the matching private key (only used in the generated inventory output)"
  type        = string
  default     = "~/.ssh/ansible-lab"
}

# ============================================
# Tags / labels
# ============================================

variable "network_tag" {
  description = "Network tag the firewall rule targets"
  type        = string
  default     = "ansible-lab-server"
}

variable "firewall_name" {
  description = "Firewall rule name"
  type        = string
  default     = "ansible-lab-allow-traffic"
}

variable "labels" {
  description = "Labels applied to the VMs"
  type        = map(string)
  default = {
    environment = "lab"
    managed-by  = "terraform"
    purpose     = "ansible-course"
  }
}
