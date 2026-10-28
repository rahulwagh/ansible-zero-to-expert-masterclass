# ── managed PostgreSQL (RDS) in the private subnets ─────────────────────────
# No database server for Ansible to configure, and no route to the internet.

resource "aws_security_group" "db" {
  name        = "${local.prefix}-db"
  description = "PostgreSQL only from the app servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  tags = merge(var.tags, { Name = "${local.prefix}-db" })
}

resource "random_password" "db" {
  length  = 24
  special = false # keeps the DATABASE_URL free of characters that need escaping
}

resource "aws_db_subnet_group" "db" {
  name       = "${local.prefix}-db"
  subnet_ids = aws_subnet.private[*].id
  tags       = merge(var.tags, { Name = "${local.prefix}-db" })
}

resource "aws_db_instance" "db" {
  identifier              = "${local.prefix}-db"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  storage_type            = "gp3"
  db_name                 = "notes"
  username                = "notes"
  password                = random_password.db.result
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 0    # demo: no backups, faster create and destroy
  skip_final_snapshot     = true # demo: destroy leaves nothing behind
  apply_immediately       = true
  tags                    = merge(var.tags, { Name = "${local.prefix}-db" })
}
