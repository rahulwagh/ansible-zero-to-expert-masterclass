# Ready-to-use Ansible inventory. Save it with:
#   terraform output -raw ansible_inventory > ../../ansible/inventory/cloud.ini
locals {
  inventory_groups = distinct(values(var.servers))
  inventory_lines = concat(
    flatten([
      for group in local.inventory_groups : concat(
        ["[${group}]"],
        [for name, g in var.servers : "${name} ansible_host=${local.public_ip[name]} private_ip=${local.private_ip[name]}" if g == group],
        [""]
      )
    ]),
    [
      "[all:vars]",
      "ansible_user=${var.ssh_user}",
      "ansible_ssh_private_key_file=${var.ssh_private_key_file}",
      "ansible_python_interpreter=/usr/bin/python3",
    ]
  )
}

output "ansible_inventory" {
  description = "Ansible inventory for ansible/inventory/cloud.ini"
  value       = "${join("\n", local.inventory_lines)}\n"
}

output "public_ips" {
  value = local.public_ip
}

output "private_ips" {
  value = local.private_ip
}
