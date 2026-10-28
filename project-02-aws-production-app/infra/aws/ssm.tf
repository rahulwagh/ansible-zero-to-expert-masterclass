# ── what Terraform hands to Ansible (read there with the ssm_parameter lookup) ─

resource "aws_ssm_parameter" "db_host" {
  name  = "${local.ssm}/db_host"
  type  = "String"
  value = aws_db_instance.db.address
  tags  = var.tags
}

resource "aws_ssm_parameter" "db_password" {
  name  = "${local.ssm}/db_password"
  type  = "SecureString"
  value = random_password.db.result
  tags  = var.tags
}

resource "aws_ssm_parameter" "target_group_arn" {
  name  = "${local.ssm}/target_group_arn"
  type  = "String"
  value = aws_lb_target_group.app.arn
  tags  = var.tags
}

resource "aws_ssm_parameter" "alb_dns" {
  name  = "${local.ssm}/alb_dns"
  type  = "String"
  value = aws_lb.app.dns_name
  tags  = var.tags
}
