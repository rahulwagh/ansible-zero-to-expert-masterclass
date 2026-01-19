# Ansible Lab Servers

Terraform configuration to provision VM instances on Google Cloud Platform for Ansible course lab environment.

## Prerequisites

- Terraform >= 1.0
- GCP project with existing VPC and subnet
- SSH key pair for VM access

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## SSH Connection

Connect to the VM instances using:

```bash
ssh -i /Users/rahulwagh/Downloads/ansible-demo/ansible-course-ssh-key ansible@<EXTERNAL_IP>
```

## Outputs

After deployment, run `terraform output` to get:
- Instance names and IPs
- SSH commands for each instance
- Ansible inventory format
