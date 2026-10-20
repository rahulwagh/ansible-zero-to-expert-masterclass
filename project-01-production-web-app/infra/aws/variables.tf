variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for every server"
  type        = string
  default     = "t3.small"
}

variable "servers" {
  description = "Server name => Ansible inventory group. Four servers = load balancer, two app servers, one database."
  type        = map(string)
  default = {
    "lb-1"  = "loadbalancers"
    "app-1" = "appservers"
    "app-2" = "appservers"
    "db-1"  = "dbservers"
  }
}

variable "ssh_user" {
  description = "User that Ansible connects as"
  type        = string
  default     = "ansible"
}

variable "ssh_public_key" {
  description = "Contents of your SSH public key. Defaults to infra/keys/lab.pub"
  type        = string
  default     = null
}

variable "ssh_private_key_file" {
  description = "Path to the matching private key (only used in the generated inventory output)"
  type        = string
  default     = "../infra/keys/lab" # relative to the ansible/ directory, where playbooks run
}

variable "allowed_cidr" {
  description = "Source range allowed to reach SSH/HTTP/HTTPS. Narrow to <your-ip>/32 if you can."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    project    = "ansible-real-world-project"
    managed-by = "terraform"
  }
}
