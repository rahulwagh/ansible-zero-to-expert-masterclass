# Project 02 · Ansible on AWS. Seven commands, same idea as project 01.
#   make infra-up    Terraform: ALB + 2 EC2 + RDS + SSM parameters   (type "yes", or AUTO=1)
#   make deps        Python + Ansible collections for AWS
#   make graph       the dynamic inventory: Ansible asks AWS who the servers are
#   make site        configure both app servers from scratch
#   make deploy      rolling deploy behind the ALB:   make deploy VERSION=1.1.0
#   make break       a deploy that fails on purpose (AI postmortem if ANTHROPIC_API_KEY is set)
#   make smoke       10 requests through the ALB + a note written into RDS
#   make infra-down  Terraform destroy: stop paying
APPROVE := $(if $(AUTO),-auto-approve,)

# macOS only: after the AWS inventory plugin has talked to the network, Apple's networking library crashes every
# forked Ansible worker that touches the network again (the SSM lookups), and Ansible reports
# "ERROR! A worker was found in a dead state". Turning off Apple's os_log activity tracing avoids the crash. Harmless on Linux.
export OS_ACTIVITY_MODE := disable
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY := YES

.PHONY: ssh-key infra-up infra-down deps graph ping site deploy break smoke url

ssh-key:
	@[ -f infra/keys/lab ] || ssh-keygen -t ed25519 -f infra/keys/lab -N "" -q && echo "SSH key ready: infra/keys/lab"
infra-up: ssh-key
	cd infra/aws && terraform init -input=false && terraform apply $(APPROVE)
infra-down:
	cd infra/aws && terraform destroy $(APPROVE)
deps:
	python3 -m pip install -q -r requirements.txt
	cd ansible && ansible-galaxy collection install -r requirements.yml -p collections
graph:
	cd ansible && ansible-inventory --graph
ping:
	cd ansible && ansible appservers -m ping
site:
	cd ansible && ansible-playbook site.yml
deploy:
	cd ansible && ansible-playbook deploy.yml $(if $(VERSION),-e app_version=$(VERSION),)
break:
	cd ansible && ansible-playbook deploy.yml -e app_version=2.0.0-broken -e db_host=db-typo.internal
smoke:
	cd ansible && ansible-playbook smoke-test.yml
url:
	@cd infra/aws && terraform output -raw alb_url && echo
