variable "name_prefix" {
  description = "Prefix for the names of everything Terraform creates"
  type        = string
  default     = "ansible-p02"
}

variable "vpc_name" {
  description = "Name tag of the VPC this project creates"
  type        = string
  default     = "ansible-p02-vpc"
}

variable "vpc_cidr" {
  description = "Address range of the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnets (one per availability zone): the load balancer and the app servers live here"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnets (one per availability zone): the database lives here, with no route to the internet"
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "region" {
  description = "AWS region (must match aws_region in ansible/inventory/group_vars/all.yml and regions: in inventory/aws_ec2.yml)"
  type        = string
  default     = "us-east-1"
}

variable "app_servers" {
  description = "Names of the app servers. One per availability zone, in this order."
  type        = list(string)
  default     = ["app-1", "app-2"]
}

variable "instance_type" {
  description = "EC2 instance type for the app servers"
  type        = string
  default     = "t3.small"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "ssh_user" {
  description = "User that Ansible connects as (created by cloud-init)"
  type        = string
  default     = "ansible"
}

variable "ssh_public_key" {
  description = "Public key text. Leave null to read infra/keys/lab.pub"
  type        = string
  default     = null
}

variable "allowed_cidr" {
  description = "Who may SSH to the app servers. Use your own IP, e.g. 203.0.113.10/32"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssm_prefix" {
  description = "Where Terraform publishes values for Ansible (Parameter Store path)"
  type        = string
  default     = "/ansible-project-02"
}

variable "tags" {
  description = "Tags on everything. Project=ansible-project-02 is what the Ansible dynamic inventory filters on."
  type        = map(string)
  default = {
    Project = "ansible-project-02"
    Env     = "demo"
  }
}
