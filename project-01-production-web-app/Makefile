# Shortcuts for the video. INV picks the inventory: docker (default) or cloud.
INV ?= docker
VAULT ?=            # password comes from .vault_pass (ansible.cfg); override with VAULT=--ask-vault-pass

.PHONY: lab-up lab-down deps ping site deploy smoke

lab-up:            ## start the 4-container local lab
	./infra/docker/lab.sh up
lab-down:
	./infra/docker/lab.sh down
deps:              ## Galaxy collections
	cd ansible && ansible-galaxy collection install -r requirements.yml -p collections
ping:
	cd ansible && ansible -i inventory/$(INV).ini all -m ping
site:              ## full stack from zero
	cd ansible && ansible-playbook -i inventory/$(INV).ini site.yml $(VAULT)
deploy:            ## rolling deploy, e.g. make deploy VERSION=1.1.0
	cd ansible && ansible-playbook -i inventory/$(INV).ini deploy.yml $(VAULT) $(if $(VERSION),-e app_version=$(VERSION),)
smoke:
	cd ansible && ansible-playbook -i inventory/$(INV).ini smoke-test.yml $(VAULT)
