variable "subscription_id" {
  description = "Azure subscription ID (az account show --query id -o tsv)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "Resource group that holds everything (delete it to clean up)"
  type        = string
  default     = "ansible-lab-rg"
}

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

variable "vm_size" {
  description = "VM size (Standard_B1s is free-tier eligible for 12 months)"
  type        = string
  default     = "Standard_B1s"
}

variable "ssh_user" {
  description = "Admin user that Ansible connects as"
  type        = string
  default     = "ansible"
}

variable "ssh_public_key" {
  description = "Contents of your SSH public key. Defaults to util/keys/ansible-lab.pub"
  type        = string
  default     = null
}

variable "ssh_private_key_file" {
  description = "Path to the matching private key (only used in the generated inventory output)"
  type        = string
  default     = "../keys/ansible-lab"
}

variable "allowed_cidr" {
  description = "Source range allowed to reach SSH/HTTP. Narrow to <your-ip>/32 if you can."
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    environment = "lab"
    managed-by  = "terraform"
    purpose     = "ansible-course"
  }
}
