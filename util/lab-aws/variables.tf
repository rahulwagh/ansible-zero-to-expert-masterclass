variable "region" {
  description = "AWS region for the lab servers"
  type        = string
  default     = "us-east-1"
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

variable "instance_type" {
  description = "EC2 instance type (t3.micro / t2.micro are free-tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "ssh_user" {
  description = "User that Ansible connects as (created by cloud-init)"
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
  description = "CIDR allowed to reach SSH/HTTP. Narrow this to <your-ip>/32 if you can."
  type        = string
  default     = "0.0.0.0/0"
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
