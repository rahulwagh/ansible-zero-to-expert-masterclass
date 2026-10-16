# Ansible Real-World Project: Deploy a Production Web App from Zero

**Terraform provisions the servers. Ansible turns them into a production stack. GitHub Actions redeploys on every push.**
Runs the same way on your laptop (Docker), Google Cloud, AWS and Azure. Pick one, the playbooks don't care.

```
                     ┌─────────────┐
   users ──HTTPS──▶  │  lb-1       │  nginx · Let's Encrypt · upstream = app servers
                     └──────┬──────┘
                 ┌──────────┴──────────┐
          ┌──────▼──────┐       ┌──────▼──────┐
          │  app-1      │       │  app-2      │   Flask "Notes API" · gunicorn · systemd
          └──────┬──────┘       └──────┬──────┘   rolling deploy with serial: 1
                 └──────────┬──────────┘
                     ┌──────▼──────┐
                     │  db-1       │   PostgreSQL 14 · password from Ansible Vault
                     └─────────────┘
```

📺 Video: *(coming)*  ·  📁 Part of the [Ansible Zero to Expert Masterclass](../) repo  ·  📝 Write-up: https://jhooq.com/ansible-real-world-project-production-web-app/
🎓 Learned the fundamentals here: [Ansible Zero to Hero (Udemy)](https://www.udemy.com/course/ansible-zero-to-hero-masterclass/)

## What's in the box

| Path | What it is |
|---|---|
| `infra/docker/` | 4 Ubuntu 22.04 containers with systemd + sshd. A free "cloud" on your laptop. |
| `infra/gcp/`, `infra/aws/`, `infra/azure/` | Terraform: 4 VMs (lb-1, app-1, app-2, db-1), firewall, and an `ansible_inventory` output |
| `app/` | The application: Flask + gunicorn + PostgreSQL. `/`, `/health`, `/api/notes` |
| `ansible/roles/common` | base packages, hostnames, `/etc/hosts` |
| `ansible/roles/postgres` | PostgreSQL, listen on the private network, DB + user (password from Vault) |
| `ansible/roles/app` | virtualenv, code, `.env`, systemd unit, health-gated restart |
| `ansible/roles/nginx_lb` | nginx upstream over all app servers, optional Let's Encrypt |
| `ansible/site.yml` | the whole stack from zero |
| `ansible/deploy.yml` | rolling deploy of a new version, zero downtime |
| `ansible/smoke-test.yml` | 10 requests through the LB, shows which server answered |
| `../.github/workflows/deploy-project-01.yml` | push to `main` → rolling deploy → smoke test |

## Prerequisites (your laptop = the Ansible control node)

- Ansible 2.15+ (`pip install ansible`)
- For the local lab: Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- For a cloud: Terraform 1.x and that cloud's CLI logged in (`gcloud` / `aws` / `az`)

```bash
git clone https://github.com/rahulwagh/ansible-zero-to-expert-masterclass.git
cd ansible-zero-to-expert-masterclass/project-01-production-web-app
make deps          # Galaxy collections (community.postgresql, community.general)
```

### The vault password

`ansible/inventory/group_vars/all/vault.yml` is encrypted. The demo password is **`ansible-demo`**;
it must be in a gitignored file at the repo root so Ansible picks it up automatically:

```bash
echo ansible-demo > .vault_pass
```

Using this for anything real? Change the secret and the password: `ansible-vault rekey ansible/inventory/group_vars/all/vault.yml`.

## Option A · Run it on your laptop with Docker (5 minutes)

```bash
make lab-up                 # creates infra/keys/lab, builds + starts lb-1 app-1 app-2 db-1, pings them
make site                   # the full stack: common → postgres → app (one at a time) → nginx
open http://localhost:8080  # the app, served by lb-1 → app-1 / app-2 → db-1
```

Rolling deploy of a new version, watch the page change with zero failed requests:

```bash
make deploy VERSION=1.1.0
make smoke                  # 10 requests through the LB: which server answered, which versions were seen
```

`make lab-down` deletes the containers.

## Option B · Google Cloud / AWS / Azure

```bash
ssh-keygen -t ed25519 -f infra/keys/lab -N ""          # once; Terraform installs the public key

cd infra/gcp                                           # or infra/aws, infra/azure
cp terraform.tfvars.example terraform.tfvars           # gcp: project_id · azure: subscription_id · aws: nothing required
terraform init && terraform apply

./../../scripts/gen-inventory.sh gcp                   # writes ansible/inventory/cloud.ini from Terraform output
cd ../..
make ping INV=cloud
make site INV=cloud
```

The Terraform output already contains every server's public IP (for Ansible) and private IP (for nginx → app and app → PostgreSQL).

**HTTPS:** point a DNS A record at lb-1's public IP, then in `ansible/inventory/group_vars/all/main.yml` set
`enable_ssl: true`, `domain_name`, `letsencrypt_email` and run `make site INV=cloud` again. certbot takes it from there.

Costs: four small VMs are roughly $0.05–0.08 per hour on any of the three clouds. `terraform destroy` when done.

## Option C · CI/CD: push to deploy

Add three repository secrets in GitHub (Settings → Secrets and variables → Actions):

| Secret | Value |
|---|---|
| `SSH_PRIVATE_KEY` | contents of `infra/keys/lab` |
| `INVENTORY_INI` | contents of `ansible/inventory/cloud.ini` |
| `VAULT_PASSWORD` | your vault password |

Now any push to `main` that touches `app/` or `ansible/` runs `deploy.yml` (version = short commit SHA, one server at a time,
health-checked) followed by `smoke-test.yml`. Change the text in `app/app.py`, push, and refresh the browser.

## How the zero-downtime deploy works

1. `deploy.yml` runs the `app` role with `serial: 1`, so only one app server is touched at a time.
2. On that server the code, dependencies and `.env` are updated, the systemd unit is restarted, and the play **waits for `/health`
   to return `ok`** before Ansible moves to the next server. If the health check fails, the play stops with one server still on the old version.
3. Meanwhile nginx on lb-1 has `max_fails=1 fail_timeout=5s` and `proxy_next_upstream`, so a request that hits the restarting
   server is retried on the healthy one. Users never see a 502.

## Inventory groups

```ini
[loadbalancers]   lb-1
[appservers]      app-1  app-2
[dbservers]       db-1
```

Every host carries `private_ip`: on the clouds it is the VPC address, on the Docker lab it is the container name
(Docker's DNS resolves it). That single variable is why the same roles work everywhere.
