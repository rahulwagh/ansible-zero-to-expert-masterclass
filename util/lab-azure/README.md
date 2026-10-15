# Lab servers on Azure (Terraform)

Three Ubuntu 22.04 VMs in a new resource group with their own VNet, subnet, public IPs and a
network security group that allows SSH, HTTP and ICMP. The admin user is `ansible` with your key.

**Cost:** `Standard_B1s` is covered by the Azure free account (750 hours a month for 12 months)
and new accounts get $200 of credit for 30 days. After that, three `B1s` VMs cost roughly
$0.03/hour total. Run `terraform destroy` (or delete the resource group) when you are done.

## Requirements

- Azure account and the Azure CLI logged in (`az login`, `az account show` works)
- Terraform >= 1.0

## 1. Create an SSH key for the lab (inside the repo)

```bash
ssh-keygen -t ed25519 -f util/keys/ansible-lab -N ""     # from the repo root; util/keys is gitignored
```

## 2. Provision

```bash
cd util/lab-azure
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: set subscription_id = $(az account show --query id -o tsv)
# the key is picked up from util/keys automatically
terraform init
terraform apply
```

When it finishes, Terraform prints the public IPs, SSH commands and a ready-made inventory block.

## 3. Point every chapter at the lab

```bash
cd ../..   # repo root
python3 util/set-lab-hosts.py --key util/keys/ansible-lab \
    --server1 <ip-1> --server2 <ip-2> --server3 <ip-3>
cd chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml
```

## Clean up

```bash
terraform destroy
```

## Options

- `location`, `vm_size`, `instance_count` in `terraform.tfvars`
- `allowed_cidr = "<your-ip>/32"` to restrict SSH/HTTP to your own IP
