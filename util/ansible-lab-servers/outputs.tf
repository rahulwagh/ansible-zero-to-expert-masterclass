# ============================================
# Output Values
# ============================================

output "instance_names" {
  description = "Names of the Ansible lab VM instances"
  value       = google_compute_instance.ansible_lab[*].name
}

output "instance_external_ips" {
  description = "External IP addresses of the Ansible lab VM instances"
  value       = google_compute_instance.ansible_lab[*].network_interface[0].access_config[0].nat_ip
}

output "instance_internal_ips" {
  description = "Internal IP addresses of the Ansible lab VM instances"
  value       = google_compute_instance.ansible_lab[*].network_interface[0].network_ip
}

output "instance_zones" {
  description = "Zones of the Ansible lab VM instances"
  value       = google_compute_instance.ansible_lab[*].zone
}

# SSH connection commands for convenience
output "ssh_commands" {
  description = "SSH commands to connect to each instance"
  value = [
    for i, instance in google_compute_instance.ansible_lab :
    "ssh -i /Users/rahulwagh/Downloads/ansible-demo/ansible-course-ssh-key ${var.ssh_user}@${instance.network_interface[0].access_config[0].nat_ip}"
  ]
}

# Ansible inventory format output
output "ansible_inventory" {
  description = "Ansible inventory format for the lab servers"
  value = <<-EOT
[ansible_lab_servers]
%{for i, instance in google_compute_instance.ansible_lab~}
${instance.name} ansible_host=${instance.network_interface[0].access_config[0].nat_ip} ansible_user=${var.ssh_user}
%{endfor~}

[ansible_lab_servers:vars]
ansible_ssh_private_key_file=/Users/rahulwagh/Downloads/ansible-demo/ansible-course-ssh-key
ansible_python_interpreter=/usr/bin/python3
EOT
}

# VPC and Subnet information
output "vpc_name" {
  description = "Name of the VPC network used"
  value       = data.google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Name of the subnet used"
  value       = data.google_compute_subnetwork.subnet.name
}

output "subnet_cidr" {
  description = "CIDR range of the subnet"
  value       = data.google_compute_subnetwork.subnet.ip_cidr_range
}
