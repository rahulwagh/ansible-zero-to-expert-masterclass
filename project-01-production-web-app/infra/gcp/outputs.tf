# Ready-to-use Ansible inventory. Save it with:
#   terraform output -raw ansible_inventory > ../../ansible/inventory/cloud.ini
output "ansible_inventory" {
  description = "Ansible inventory for ansible/inventory/cloud.ini"
  value       = <<-EOT
    %{for group in distinct(values(var.servers))~}
    [${group}]
    %{for name, g in var.servers~}
    %{if g == group~}
    ${name} ansible_host=${local.public_ip[name]} private_ip=${local.private_ip[name]}
    %{endif~}
    %{endfor~}

    %{endfor~}
    [all:vars]
    ansible_user=${var.ssh_user}
    ansible_ssh_private_key_file=${var.ssh_private_key_file}
    ansible_python_interpreter=/usr/bin/python3
  EOT
}

output "public_ips" {
  value = local.public_ip
}

output "private_ips" {
  value = local.private_ip
}
