# ============================================
# Project Variables
# ============================================

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-north2"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "europe-north2-a"
}

# ============================================
# VPC Variables (Using existing VPC from GCP course)
# ============================================

variable "vpc_name" {
  description = "Name of the existing VPC network"
  type        = string
  default     = "cl-vpc-sandbox"
}

variable "subnet_name" {
  description = "Name of the existing subnet"
  type        = string
  default     = "cl-sub-sandbox-web-eu-nrth2-01"
}

# ============================================
# VM Instance Variables
# ============================================

variable "instance_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 3
}

variable "instance_name_prefix" {
  description = "Prefix for the VM instance names"
  type        = string
  default     = "ansible-lab-server"
}

variable "machine_type" {
  description = "Machine type for the VM instances"
  type        = string
  default     = "e2-micro"
}

variable "vm_image" {
  description = "Boot disk image for the VM instances"
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
# SSH Variables
# ============================================

variable "ssh_user" {
  description = "SSH username for the VM instances"
  type        = string
  default     = "ansible"
}

variable "ssh_public_key" {
  description = "SSH public key content for VM access"
  type        = string
}

# ============================================
# Network Tag
# ============================================

variable "network_tag" {
  description = "Network tag for the VM instances"
  type        = string
  default     = "ansible-lab-server"
}

# ============================================
# Firewall Variables
# ============================================

variable "firewall_name" {
  description = "Name of the firewall rule for Ansible lab servers"
  type        = string
  default     = "ansible-lab-allow-traffic"
}

# ============================================
# Labels
# ============================================

variable "labels" {
  description = "Labels to apply to the VM instances"
  type        = map(string)
  default = {
    environment = "lab"
    managed-by  = "terraform"
    purpose     = "ansible-course"
  }
}
