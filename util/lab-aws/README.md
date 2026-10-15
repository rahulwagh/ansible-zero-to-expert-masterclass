# Lab servers on AWS (Terraform)

Three Ubuntu 22.04 EC2 instances in your account's **default VPC** with a security group that
allows SSH, HTTP and ICMP. An `ansible` user with your key is created by cloud-init.

**Cost:** `t3.micro`/`t2.micro` are covered by the AWS Free Tier for new accounts (750 hours a
month for 12 months, or free-tier credits on accounts created after July 2025). After that, three
`t3.micro` instances cost roughly $0.03/hour total. Run `terraform destroy` when you are done.

## Requirements

- AWS account and the AWS CLI configured (`aws configure`, `aws sts get-caller-identity` works)
- Terraform >= 1.0

## 1. Create an SSH key for the lab (inside the repo)

```bash
ssh-keygen -t ed25519 -f util/keys/ansible-lab -N ""     # from the repo root; util/keys is gitignored
```

## 2. Provision

```bash
cd util/lab-aws
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars if you want to change region/size; the key is picked up from util/keys automatically
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

The first SSH may take a minute while cloud-init finishes installing Python.

## Clean up

```bash
terraform destroy
```

## Options

- `region`, `instance_type`, `instance_count` in `terraform.tfvars`
- `allowed_cidr = "<your-ip>/32"` to restrict SSH/HTTP to your own IP
