# ============================================
# Ansible lab servers on AWS (default VPC)
# ============================================

# Use the account's default VPC so no networking has to be built
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Latest Ubuntu 22.04 LTS AMI published by Canonical for this region
data "aws_ssm_parameter" "ubuntu_2204" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# ============================================
# Security group: SSH, HTTP, ICMP
# ============================================

resource "aws_security_group" "ansible_lab" {
  name        = "${var.instance_name_prefix}-sg"
  description = "Allow SSH, HTTP and ICMP to Ansible lab servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.instance_name_prefix}-sg" })
}

# ============================================
# Lab servers
# ============================================

resource "aws_instance" "ansible_lab" {
  count = var.instance_count

  ami                         = data.aws_ssm_parameter.ubuntu_2204.value
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.ansible_lab.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # cloud-init: create the "ansible" user with your key and make sure Python exists
  user_data = <<-EOF
    #cloud-config
    hostname: ${var.instance_name_prefix}-${count.index + 1}
    manage_etc_hosts: true
    users:
      - name: ${var.ssh_user}
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: true
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    package_update: true
    packages:
      - python3
      - python3-apt
  EOF

  tags = merge(var.tags, { Name = "${var.instance_name_prefix}-${count.index + 1}" })
}
