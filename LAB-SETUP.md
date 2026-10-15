# Lab Setup: Where to Run the Playbooks

Every chapter in this course runs playbooks against **three Ubuntu 22.04 servers** named
`ansible-lab-server-1`, `-2` and `-3`. Where those servers live is up to you. Pick **one** option
below; they all end up identical from Ansible's point of view.

| Option | Cost | Needs | Best for |
|---|---|---|---|
| [A. Docker on your laptop](#option-a-docker-on-your-laptop) | Free | Docker Desktop | Fastest start, works offline |
| [B. Multipass VMs on your laptop](#option-b-multipass-vms-on-your-laptop) | Free | Multipass, ~3 GB RAM | Real VMs without a cloud account |
| [C. Google Cloud](#option-c-google-cloud-gcp) | Free tier / ~$0.03 per hour | GCP account, Terraform | Same setup as the course videos |
| [D. AWS](#option-d-aws) | Free tier / ~$0.03 per hour | AWS account, Terraform | You already use AWS |
| [E. Azure](#option-e-azure) | Free tier / ~$0.03 per hour | Azure account, Terraform | You already use Azure |
| [F. Other free options](#option-f-other-free-options) | Free | Varies | Oracle Always Free, Codespaces, any VPS |

> **Not sure?** Start with **Option A (Docker)**. It takes five minutes, costs nothing, and every
> playbook in the course works on it. Move to a cloud option later if you want the real thing.

---

## Before you start (all options)

### 1. Install Ansible on your machine (the control node)

Follow [`Ansible_Installation.md`](./Ansible_Installation.md) (macOS / Linux) or
[`Ansible_Installation_WSL.md`](./Ansible_Installation_WSL.md) (Windows). Verify:

```bash
ansible --version
```

### 2. Clone the repo

```bash
git clone https://github.com/rahulwagh/ansible-zero-to-expert-masterclass.git
cd ansible-zero-to-expert-masterclass
```

### 3. Create one SSH key for the lab, inside the repo

```bash
ssh-keygen -t ed25519 -f util/keys/ansible-lab -N ""
```

Everything lives in the repo folder: `util/keys/` is gitignored, every option below installs
`util/keys/ansible-lab.pub` on the servers, and Ansible connects with `util/keys/ansible-lab`.
The user on the servers is always `ansible`. (The Docker option's `lab.sh up` creates the key for you.)

---

## Option A: Docker on your laptop

Three containers that run systemd, sshd and Python, so they behave like small servers.
Full details: [`util/lab-local-docker/README.md`](./util/lab-local-docker/README.md)

```bash
cd util/lab-local-docker
./lab.sh up                        # key + build + start + wire chapters + ping, ~2 minutes the first time
cd ../../chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml
```

Step by step, `lab.sh up` runs: `ssh-keygen` into `util/keys/`, `cp .env.example .env`,
`docker compose up -d --build`, `python3 util/set-lab-hosts.py --docker`, `ansible all -m ping`.

| Server | SSH | HTTP |
|---|---|---|
| ansible-lab-server-1 | 127.0.0.1:2221 | http://localhost:8081 |
| ansible-lab-server-2 | 127.0.0.1:2222 | http://localhost:8082 |
| ansible-lab-server-3 | 127.0.0.1:2223 | http://localhost:8083 |

Pause with `./lab.sh stop`, resume with `./lab.sh start`, delete with `./lab.sh down`.

---

## Option B: Multipass VMs on your laptop

[Multipass](https://multipass.run) (free, by Canonical) creates real Ubuntu VMs on macOS, Windows
and Linux. Full details: [`util/lab-local-multipass/README.md`](./util/lab-local-multipass/README.md)

```bash
brew install multipass            # macOS; see multipass.run for Windows/Linux
cd util/lab-local-multipass
chmod +x *.sh && ./create-lab.sh  # launches 3 VMs and prints their IPs

cd ../..
python3 util/set-lab-hosts.py --server1 <ip-1> --server2 <ip-2> --server3 <ip-3>
cd chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml
```

Delete everything with `./destroy-lab.sh`.

---

## Option C: Google Cloud (GCP)

This is what the course videos use. Terraform creates a VPC, firewall rule and three VMs.
Full details: [`util/lab-gcp/README.md`](./util/lab-gcp/README.md)

**Free tier:** one `e2-micro` in `us-west1`, `us-central1` or `us-east1` is always free; the other
two cost about $0.01/hour each. New accounts get $300 credit for 90 days.

```bash
gcloud auth application-default login
cd util/lab-gcp
cp terraform.tfvars.example terraform.tfvars   # set project_id; the key is read from util/keys
terraform init && terraform apply              # prints IPs + an inventory block

cd ../..
python3 util/set-lab-hosts.py --server1 <ip-1> --server2 <ip-2> --server3 <ip-3>
```

Stop the VMs between sessions (`gcloud compute instances stop ...`) and `terraform destroy` when done.

---

## Option D: AWS

Terraform creates three EC2 instances in your default VPC with a security group.
Full details: [`util/lab-aws/README.md`](./util/lab-aws/README.md)

**Free tier:** `t3.micro`/`t2.micro` for 750 hours a month in the first 12 months (or free-tier
credits on newer accounts). Otherwise about $0.03/hour for all three.

```bash
aws configure                     # once
cd util/lab-aws
cp terraform.tfvars.example terraform.tfvars   # optional edits; the key is read from util/keys
terraform init && terraform apply

cd ../..
python3 util/set-lab-hosts.py --server1 <ip-1> --server2 <ip-2> --server3 <ip-3>
```

`terraform destroy` when done.

---

## Option E: Azure

Terraform creates a resource group, VNet, NSG and three `Standard_B1s` VMs.
Full details: [`util/lab-azure/README.md`](./util/lab-azure/README.md)

**Free tier:** `B1s` for 750 hours a month in the first 12 months, plus $200 credit for 30 days.
Otherwise about $0.03/hour for all three.

```bash
az login                          # once
cd util/lab-azure
cp terraform.tfvars.example terraform.tfvars   # set subscription_id; the key is read from util/keys
terraform init && terraform apply

cd ../..
python3 util/set-lab-hosts.py --server1 <ip-1> --server2 <ip-2> --server3 <ip-3>
```

`terraform destroy` (or delete the resource group) when done.

---

## Option F: Other free options

Any Linux machine you can SSH into works. Create the `ansible` user with your key on it, then
run `set-lab-hosts.py` with its IP. Some free places to get one:

- **Oracle Cloud Always Free** – permanently free: up to 4 ARM cores and 24 GB RAM split across
  up to 4 VMs, plus 2 AMD micro VMs. The most generous free tier available. Use Ubuntu 22.04
  images. Note: Oracle sometimes reclaims idle Always Free instances, so keep them in use.
- **GitHub Codespaces** – 60 free hours a month on a 2-core machine. Open this repo in a
  Codespace, then follow **Option A**: Docker is pre-installed, so `docker compose up -d --build`
  works there without installing anything locally.
- **Hetzner / DigitalOcean / Linode / Vultr** – not free, but the smallest VMs cost about
  $4–6 per month each and are often cheaper than cloud free tiers after they expire.
- **An old laptop, Raspberry Pi, Proxmox or VirtualBox VM** – anything running Ubuntu with
  SSH enabled.

**Only have one or two machines?** Reuse an IP for two names, the playbooks still work:

```bash
python3 util/set-lab-hosts.py --server1 10.0.0.5 --server2 10.0.0.5 --server3 10.0.0.6
```

---

## How the inventories work

Each chapter has its own `inventory/hosts.ini` (chapter 1 uses a file called `inventory`). They
all reference the same three names and groups:

```ini
[webservers]
ansible-lab-server-1 ansible_host=<ip>
ansible-lab-server-2 ansible_host=<ip>

[dbservers]
ansible-lab-server-3 ansible_host=<ip>

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=/full/path/to/repo/util/keys/ansible-lab
ansible_python_interpreter=/usr/bin/python3
```

`python3 util/set-lab-hosts.py` rewrites the IPs, ports and key path in every chapter at once.
Run it again whenever your IPs change (cloud VMs get new public IPs after a stop/start).

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Permission denied (publickey)` | Wrong key path in the inventory, or the public key is not on the server. Check `util/keys/ansible-lab` exists and re-run `set-lab-hosts.py`. |
| `UNREACHABLE` on a cloud VM right after `terraform apply` | cloud-init is still installing Python. Wait 1–2 minutes and retry. |
| `/usr/bin/python3: not found` | Install Python on the server: `sudo apt-get install -y python3`. The Terraform and Docker labs do this for you. |
| Host key warnings | Every chapter's `ansible.cfg` sets `host_key_checking = False`; run playbooks from inside the chapter folder. |
| IPs changed after restarting cloud VMs | Re-run `set-lab-hosts.py` with the new IPs. |
| Docker: `docker compose up` fails on `cgroup` | Update Docker Desktop, or add `cgroup: host` as described in `util/lab-local-docker/README.md`. |
| Docker: `Docker is installed but not running` | Start Docker Desktop (wait for the whale icon), then `./lab.sh up` again. |
