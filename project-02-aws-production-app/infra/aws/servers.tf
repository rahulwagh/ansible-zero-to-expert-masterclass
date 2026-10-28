# ── the two app servers (Ansible configures these) ──────────────────────────

data "aws_ssm_parameter" "ubuntu_2204" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_security_group" "app" {
  name        = "${local.prefix}-app"
  description = "App servers: port 8000 only from the ALB, SSH only from you"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${local.prefix}-app" })
}

resource "aws_instance" "app" {
  count                       = length(var.app_servers)
  ami                         = data.aws_ssm_parameter.ubuntu_2204.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # Only creates the "ansible" user and installs your public key.
  # No packages here: a boot-time apt run would race Ansible for the apt lock.
  user_data = <<-EOF
    #cloud-config
    hostname: ${var.app_servers[count.index]}
    manage_etc_hosts: true
    users:
      - name: ${var.ssh_user}
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: true
        ssh_authorized_keys:
          - ${local.ssh_public_key}
  EOF

  # Role=app is what the dynamic inventory turns into the "appservers" group
  tags = merge(var.tags, { Name = var.app_servers[count.index], Role = "app" })

  depends_on = [aws_route.public_internet]
}
