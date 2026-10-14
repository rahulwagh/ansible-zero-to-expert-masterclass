# Lab servers on Google Cloud (Terraform)

Three Ubuntu 22.04 VMs with their own VPC, subnet and a firewall rule that allows SSH, HTTP and
ICMP. The `ansible` user with your key is added through instance metadata. This is the setup used
in the course videos.

**Cost:** one `e2-micro` in `us-west1`, `us-central1` or `us-east1` is in the GCP **Always Free**
tier; the other two cost roughly $0.01/hour each. New accounts also get $300 of credit for 90 days.
Run `terraform destroy` when you are done.

## Requirements

- GCP project with billing enabled and the Compute Engine API turned on
- `gcloud` CLI logged in (`gcloud auth application-default login`)
- Terraform >= 1.0

## 1. Create an SSH key for the lab

```bash
ssh-keygen -t ed25519 -f ~/.ssh/ansible-lab -N ""
```

## 2. Provision

```bash
cd util/lab-gcp
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: project_id and paste the contents of ~/.ssh/ansible-lab.pub into ssh_public_key
terraform init
terraform apply
```

When it finishes, Terraform prints the external IPs, SSH commands and a ready-made inventory block.

## 3. Point every chapter at the lab

```bash
cd ../..   # repo root
python3 util/set-lab-hosts.py --key ~/.ssh/ansible-lab \
    --server1 <ip-1> --server2 <ip-2> --server3 <ip-3>
cd chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml
```

The first SSH may take a minute while the startup script installs Python.

## Clean up

```bash
terraform destroy
```

## Options

- `region` / `zone`, `machine_type`, `instance_count` in `terraform.tfvars`
- `create_network = false` plus `vpc_name` / `subnet_name` to reuse an existing network
- `allowed_cidr = "<your-ip>/32"` to restrict SSH/HTTP to your own IP
- Stopped VMs are not billed for compute. `gcloud compute instances stop ansible-lab-server-1 --zone <zone>`
  between study sessions; external IPs change on restart, so re-run `set-lab-hosts.py`.
