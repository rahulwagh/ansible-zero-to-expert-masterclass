output "instance_names" {
  description = "Names of the lab servers"
  value       = google_compute_instance.ansible_lab[*].name
}

output "instance_external_ips" {
  description = "External IPs of the lab servers"
  value       = google_compute_instance.ansible_lab[*].network_interface[0].access_config[0].nat_ip
}

output "instance_internal_ips" {
  description = "Internal IPs of the lab servers"
  value       = google_compute_instance.ansible_lab[*].network_interface[0].network_ip
}

output "ssh_commands" {
  description = "SSH into each server"
  value = [
    for i in google_compute_instance.ansible_lab :
    "ssh -i ${var.ssh_private_key_file} ${var.ssh_user}@${i.network_interface[0].access_config[0].nat_ip}"
  ]
}

output "ansible_inventory" {
  description = "Paste into inventory/hosts.ini"
  value       = <<-EOT
    [webservers]
    %{for i in slice(google_compute_instance.ansible_lab, 0, max(var.instance_count - 1, 1))~}
    ${i.name} ansible_host=${i.network_interface[0].access_config[0].nat_ip}
    %{endfor~}

    [dbservers]
    ${google_compute_instance.ansible_lab[var.instance_count - 1].name} ansible_host=${google_compute_instance.ansible_lab[var.instance_count - 1].network_interface[0].access_config[0].nat_ip}

    [production:children]
    webservers
    dbservers

    [all:vars]
    ansible_user=${var.ssh_user}
    ansible_ssh_private_key_file=${var.ssh_private_key_file}
    ansible_python_interpreter=/usr/bin/python3
  EOT
}

output "network_name" {
  description = "VPC network used"
  value       = local.network_name
}
