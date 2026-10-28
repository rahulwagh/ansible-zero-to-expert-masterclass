/*output "alb_url" {
  description = "Open this in the browser once Ansible has deployed the app"
  value       = "http://${aws_lb.app.dns_name}"
}

output "app_public_ips" {
  description = "For SSH if you want to look around. Ansible finds them itself (dynamic inventory)."
  value       = { for i in aws_instance.app : i.tags["Name"] => i.public_ip }
}

output "rds_endpoint" {
  value = aws_db_instance.db.address
}

output "ssm_prefix" {
  value = var.ssm_prefix
}

output "vpc" {
  description = "The VPC this project created"
  value       = { name = var.vpc_name, id = aws_vpc.main.id, cidr = aws_vpc.main.cidr_block }
}

output "subnets" {
  value = {
    public  = { for s in aws_subnet.public : s.tags["Name"] => s.cidr_block }
    private = { for s in aws_subnet.private : s.tags["Name"] => s.cidr_block }
  }
}*/
