output "instance_names" {
  description = "Names of the lab servers"
  value       = aws_instance.ansible_lab[*].tags["Name"]
}

output "instance_public_ips" {
  description = "Public IPs of the lab servers"
  value       = aws_instance.ansible_lab[*].public_ip
}

output "ssh_commands" {
  description = "SSH into each server"
  value = [
    for i in aws_instance.ansible_lab :
    "ssh -i ${var.ssh_private_key_file} ${var.ssh_user}@${i.public_ip}"
  ]
}

output "ansible_inventory" {
  description = "Paste into inventory/hosts.ini"
  value       = <<-EOT
    [webservers]
    %{for i in slice(aws_instance.ansible_lab, 0, max(var.instance_count - 1, 1))~}
    ${i.tags["Name"]} ansible_host=${i.public_ip}
    %{endfor~}

    [dbservers]
    ${aws_instance.ansible_lab[var.instance_count - 1].tags["Name"]} ansible_host=${aws_instance.ansible_lab[var.instance_count - 1].public_ip}

    [production:children]
    webservers
    dbservers

    [all:vars]
    ansible_user=${var.ssh_user}
    ansible_ssh_private_key_file=${var.ssh_private_key_file}
    ansible_python_interpreter=/usr/bin/python3
  EOT
}
