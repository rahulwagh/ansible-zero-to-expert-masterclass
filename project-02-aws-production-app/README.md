# Project 02 · Ansible on AWS (ALB + RDS + dynamic inventory + AI postmortem)

Part 2 of the Ansible real-world project series. Part 1 ran on Docker on your laptop ([project-01](../project-01-production-web-app/)). This part runs on AWS the way a team would.

```
   VPC (yours)
   users ──▶ ALB ──▶ app-1 (public subnet 1) ─┐
                 └─▶ app-2 (public subnet 2) ─┴──▶ RDS PostgreSQL (private subnets)

   Terraform builds the AWS side and publishes db host, password, target group to SSM Parameter Store.
   Ansible finds the servers (dynamic inventory), reads SSM, configures them, and rolls out new versions.
```

## What is different from Project 01

| | Project 01 | Project 02 |
|---|---|---|
| Load balancer | nginx role | Application Load Balancer (Terraform) |
| Database | PostgreSQL role | RDS PostgreSQL 16, private (Terraform) |
| Inventory | `docker.ini` | `aws_ec2.yml`, a filter that asks AWS |
| Secrets | Ansible Vault | SSM Parameter Store, read with a lookup |
| Rolling deploy | nginx retries | drain from the ALB, deploy, wait until the ALB says healthy |
| Extra | | `ai_postmortem` role: on a failed deploy, send the logs to Claude and print the root cause (optional) |

## Prerequisites

AWS credentials (`aws sts get-caller-identity` works), Terraform 1.x, Python 3 with `boto3`, Ansible 2.18+. Optional: `ANTHROPIC_API_KEY` for the AI postmortem.

**On a Mac**, run this once in every terminal where you call `ansible-playbook` directly (the `make` commands already set it):

```bash
export OS_ACTIVITY_MODE=disable
```

Without it, any task that reads SSM fails with `ERROR! A worker was found in a dead state` (macOS crashes Ansible's worker process, see the post for the crash-report details). Also check that `ansible --version` says 2.18 or newer, and that its Python has `boto3`.

## Run it (about 10 cents an hour while it exists)

```bash
make deps          # boto3 + amazon.aws + community.aws
make infra-up      # Terraform: ALB, 2 EC2, RDS, SSM parameters (type yes)
make graph         # Ansible asks AWS for the servers
make site          # configure both app servers
make smoke         # 10 requests through the ALB + a note written into RDS
make deploy VERSION=1.1.0
make break         # a bad deploy on purpose: the ALB protects users, Claude explains why
make infra-down    # terraform destroy
```

Set `allowed_cidr` in `infra/aws/terraform.tfvars` to your own IP (`x.x.x.x/32`) before `make infra-up`. The project creates its own VPC; name it with `vpc_name` (default `ansible-p02-vpc`) and size it with `vpc_cidr` and the subnet lists in `variables.tf`.

## Prefer to go step by step?

`site.yml` is tagged, so you can run it one piece at a time instead of `make site`:

```bash
cd ansible
ansible-playbook site.yml --list-tasks                                       # the plan
ansible-playbook site.yml --tags common                                      # base packages
ansible-playbook site.yml --tags app_packages                                # python3-venv
ansible-playbook site.yml --tags app_user                                    # user + directories
ansible-playbook site.yml --tags app_code                                    # copy the Flask app
ansible-playbook site.yml --tags app_deps                                    # virtualenv + requirements
ansible-playbook site.yml --tags app_config                                  # .env (RDS password from SSM)
ansible-playbook site.yml --tags app_service,app_health --limit app-1        # start the app on ONE server: ALB shows 1 healthy
ansible-playbook site.yml --tags app_service,app_health --limit app-2        # then the other
ansible-playbook site.yml --tags verify                                      # ask the ALB
```

Keep that order (`app_service` needs the `.env` from `app_config`). `--step` asks before every task, `--check --diff` shows what would change. The full recorded walkthrough is `manual-steps-walkthrough.md` next to the recording plan.

## Layout

| Path | What |
|---|---|
| `infra/aws/` | Terraform, one file per layer: `network.tf` (VPC, public and private subnets), `loadbalancer.tf`, `servers.tf`, `database.tf`, `ssm.tf` |
| `ansible/inventory/aws_ec2.yml` | dynamic inventory (filter on tag `Project=ansible-project-02`) |
| `ansible/inventory/group_vars/all.yml` | variables, with SSM lookups for secrets |
| `ansible/roles/common`, `app` | packages; the Flask app, systemd unit, health check |
| `ansible/roles/ai_postmortem` | evidence + Claude Messages API call, runs from `rescue` |
| `ansible/site.yml`, `deploy.yml`, `smoke-test.yml` | the three playbooks |
| `app/` | the same Notes API as Project 01 |

The Terraform state holds the generated database password. It is gitignored: keep it that way.
