# ============================================
# Ansible real-world project · AWS (default VPC)
# 4 Ubuntu 22.04 EC2 instances: lb-1, app-1, app-2, db-1
# ============================================

# Public key: explicit variable, or the repo-local infra/keys/lab.pub
locals {
  ssh_public_key = coalesce(var.ssh_public_key, trimspace(file("${path.module}/../keys/lab.pub")))
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ssm_parameter" "ubuntu_2204" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_security_group" "project" {
  name        = "ansible-project-sg"
  description = "Ansible real-world project"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = [22, 80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.allowed_cidr]
    }
  }

  # anything between the servers themselves (app -> postgres 5432, lb -> app 8000)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "ansible-project-sg" })
}

resource "aws_instance" "server" {
  for_each                    = var.servers
  ami                         = data.aws_ssm_parameter.ubuntu_2204.value
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.project.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #cloud-config
    hostname: ${each.key}
    manage_etc_hosts: true
    users:
      - name: ${var.ssh_user}
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: true
        ssh_authorized_keys:
          - ${local.ssh_public_key}
    package_update: true
    packages: [python3, python3-apt]
  EOF

  tags = merge(var.tags, { Name = each.key, group = each.value })
}

locals {
  public_ip  = { for k, i in aws_instance.server : k => i.public_ip }
  private_ip = { for k, i in aws_instance.server : k => i.private_ip }
}
