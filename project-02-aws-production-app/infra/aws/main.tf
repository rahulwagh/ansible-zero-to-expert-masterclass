# ===========================================================================
# Ansible real-world project 02 · AWS
#
#   internet ──▶ ALB ──▶ app-1 (public subnet 1) ─┐
#                    └─▶ app-2 (public subnet 2) ─┴──▶ RDS (private subnets)
#
# One file per layer, so each one is short enough to read in a minute:
#   network.tf        VPC, subnets, internet gateway, route tables
#   loadbalancer.tf   security group, ALB, target group, listener
#   servers.tf        security group, the two app EC2 instances
#   database.tf       security group, RDS PostgreSQL
#   ssm.tf            the values Terraform publishes for Ansible
# ===========================================================================

locals {
  prefix         = var.name_prefix
  ssm            = var.ssm_prefix
  ssh_public_key = coalesce(var.ssh_public_key, trimspace(file("${path.module}/../keys/lab.pub")))
}

data "aws_availability_zones" "available" {
  state = "available"
}
