output "resource_group" {
  description = "Resource group holding the lab (delete it to clean up everything)"
  value       = azurerm_resource_group.lab.name
}

output "instance_names" {
  description = "Names of the lab servers"
  value       = azurerm_linux_virtual_machine.lab[*].name
}

output "instance_public_ips" {
  description = "Public IPs of the lab servers"
  value       = azurerm_public_ip.lab[*].ip_address
}

output "ssh_commands" {
  description = "SSH into each server"
  value = [
    for i, vm in azurerm_linux_virtual_machine.lab :
    "ssh -i ${var.ssh_private_key_file} ${var.ssh_user}@${azurerm_public_ip.lab[i].ip_address}"
  ]
}

output "ansible_inventory" {
  description = "Paste into inventory/hosts.ini"
  value       = <<-EOT
    [webservers]
    %{for i in range(max(var.instance_count - 1, 1))~}
    ${azurerm_linux_virtual_machine.lab[i].name} ansible_host=${azurerm_public_ip.lab[i].ip_address}
    %{endfor~}

    [dbservers]
    ${azurerm_linux_virtual_machine.lab[var.instance_count - 1].name} ansible_host=${azurerm_public_ip.lab[var.instance_count - 1].ip_address}

    [production:children]
    webservers
    dbservers

    [all:vars]
    ansible_user=${var.ssh_user}
    ansible_ssh_private_key_file=${var.ssh_private_key_file}
    ansible_python_interpreter=/usr/bin/python3
  EOT
}
