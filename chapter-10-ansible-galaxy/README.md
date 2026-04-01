# Chapter 10 - Ansible Galaxy

Use Ansible Galaxy to install community roles and collections, pin versions with `requirements.yml`, and build real infrastructure without writing everything from scratch.

## What You'll Learn

- What Ansible Galaxy is and why it matters
- Installing roles with `ansible-galaxy role install`
- Installing collections with `ansible-galaxy collection install`
- Using `requirements.yml` to declare and pin all dependencies
- Fully Qualified Collection Names (FQCN)
- Passing variables to override role defaults
- Real-world: deploying a LAMP stack using only Galaxy roles and collections

---

## Quick Start

```bash
cd chapter-10-ansible-galaxy

# Install all roles and collections declared in requirements.yml
ansible-galaxy install -r requirements.yml

# Verify what's installed
ansible-galaxy role list
ansible-galaxy collection list

# Run the practical playbook
ansible-playbook 04-galaxy-practical.yml
```

---

## Directory Structure

```
chapter-10-ansible-galaxy/
├── ansible.cfg
├── inventory/
│   └── hosts.ini
├── slides/
│   ├── chapter-10-presentation.md    # Marp source (editable)
│   └── chapter-10-presentation.pptx  # PowerPoint slide deck
├── 01-install-role.yml          # Install and use a Galaxy role
├── 02-install-collection.yml    # Install and use a Galaxy collection
├── 03-requirements.yml          # Declare all role + collection dependencies
├── 04-galaxy-practical.yml      # Real-world LAMP stack deployment
└── README.md
```

---

## Playbooks

| # | Playbook | Concepts Covered |
|---|----------|------------------|
| 01 | install-role.yml | `ansible-galaxy role install`, role variables, pre/post tasks, multiple roles |
| 02 | install-collection.yml | `ansible-galaxy collection install`, FQCN, community.general, community.mysql, ansible.posix |
| 03 | requirements.yml | `roles:` + `collections:` blocks, version pinning, Git sources |
| 04 | galaxy-practical.yml | Full LAMP stack: Nginx + PHP + MySQL + firewall via roles and collections |

---

## Run the Playbooks

### Playbook 01: Install a Role

```bash
# Install the role first
ansible-galaxy role install geerlingguy.nginx geerlingguy.git

# Run the playbook
ansible-playbook 01-install-role.yml

# Verbose — see every task from the role
ansible-playbook 01-install-role.yml -v
```

**Covers:** installing a Galaxy role, passing variables to override defaults, `pre_tasks`/`post_tasks`, applying multiple roles

---

### Playbook 02: Install a Collection

```bash
# Install collections first
ansible-galaxy collection install community.general community.mysql ansible.posix

# Run the playbook
ansible-playbook 02-install-collection.yml

# Check mode — preview without changes
ansible-playbook 02-install-collection.yml --check
```

**Covers:** installing collections, FQCN usage, `community.general`, `community.mysql`, `ansible.posix`, `ansible.builtin.*`

---

### Playbook 03: requirements.yml

```bash
# Install everything declared in requirements.yml at once
ansible-galaxy install -r 03-requirements.yml

# Install to a local ./roles directory (keeps project self-contained)
ansible-galaxy install -r 03-requirements.yml -p ./roles

# Force re-download/update all dependencies
ansible-galaxy install -r 03-requirements.yml --force
```

**Covers:** `roles:` block, `collections:` block, version pinning, GitHub sources, upgrading with `--force`

---

### Playbook 04: Practical LAMP Stack

```bash
# Step 1: install all dependencies
ansible-galaxy install -r requirements.yml

# Step 2: dry-run
ansible-playbook 04-galaxy-practical.yml --check --diff

# Step 3: deploy
ansible-playbook 04-galaxy-practical.yml

# Step 4: verify
curl http://<webserver-ip>/
```

**Covers:** multi-play deployment, Nginx + PHP + MySQL roles, `ansible.posix.firewalld`, host-group conditionals, `hostvars`

---

## Galaxy CLI Quick Reference

### Roles

```bash
# Install a role
ansible-galaxy role install geerlingguy.nginx

# Install a specific version
ansible-galaxy role install geerlingguy.nginx,3.1.0

# List installed roles
ansible-galaxy role list

# Remove a role
ansible-galaxy role remove geerlingguy.nginx

# Search Galaxy
ansible-galaxy search nginx --author geerlingguy

# Show role info
ansible-galaxy role info geerlingguy.nginx
```

### Collections

```bash
# Install a collection
ansible-galaxy collection install community.general

# Install a specific version
ansible-galaxy collection install community.mysql:3.9.0

# List installed collections
ansible-galaxy collection list

# Show collection info
ansible-galaxy collection list community.general

# Upgrade a collection
ansible-galaxy collection install community.general --upgrade
```

### requirements.yml

```bash
# Install all roles and collections
ansible-galaxy install -r requirements.yml

# Install to local ./roles directory
ansible-galaxy install -r requirements.yml -p ./roles

# Force reinstall / update
ansible-galaxy install -r requirements.yml --force
```

---

## Key Concepts

### Roles vs Collections

```
┌─────────────────┬────────────────────────────────┬───────────────────────────────┐
│ Feature         │ Role                           │ Collection                    │
├─────────────────┼────────────────────────────────┼───────────────────────────────┤
│ What it contains│ tasks, handlers, vars, templates│ modules, plugins, roles, docs │
│ Install command │ ansible-galaxy role install    │ ansible-galaxy collection     │
│                 │                                │   install                     │
│ Reference in    │ roles: or include_role         │ namespace.collection.module   │
│   playbook      │                                │   (FQCN)                      │
│ Default install │ ~/.ansible/roles/              │ ~/.ansible/collections/       │
│   location      │                                │                               │
│ Version pin     │ name: role, version: "1.0.0"   │ name: ns.col, version: "1.0.0"│
└─────────────────┴────────────────────────────────┴───────────────────────────────┘
```

### Fully Qualified Collection Name (FQCN)

Always use FQCN inside roles and collections to avoid ambiguity when multiple collections are installed.

```yaml
# Short name — works but can clash with another collection's module
- copy:
    src: file.txt
    dest: /tmp/file.txt

# FQCN — unambiguous, best practice
- ansible.builtin.copy:
    src: file.txt
    dest: /tmp/file.txt

# Community module — FQCN is required
- community.mysql.mysql_db:
    name: appdb
    state: present
```

### requirements.yml Structure

```yaml
---
roles:
  - name: geerlingguy.nginx           # from Galaxy
    version: "3.1.0"                  # pin version

  - name: my_role                     # from GitHub
    src: https://github.com/org/repo
    version: main
    scm: git

collections:
  - name: community.general           # from Galaxy
  - name: community.mysql
    version: "3.9.0"                  # pin version
  - name: ansible.posix
    source: https://galaxy.ansible.com
```

### Overriding Role Defaults

Every role has a `defaults/main.yml`. Override any variable in your playbook `vars:` or in inventory:

```yaml
- name: Deploy Nginx with custom config
  hosts: webservers
  become: true

  vars:
    nginx_listen_port: 8080          # overrides role default of 80
    nginx_remove_default_vhost: true # remove the default vhost

  roles:
    - geerlingguy.nginx
```

Check a role's available variables:

```bash
cat ~/.ansible/roles/geerlingguy.nginx/defaults/main.yml
```

### Where Are Roles/Collections Installed?

```bash
# Default role paths (in order of precedence)
./roles/                         # project-local (highest priority)
~/.ansible/roles/                # user-level
/usr/share/ansible/roles/        # system-level

# Default collection path
~/.ansible/collections/ansible_collections/

# Override role path in ansible.cfg
[defaults]
roles_path = ./roles:~/.ansible/roles
```

---

## Key Takeaways

1. **`ansible-galaxy role install`** — downloads a role from Galaxy into `~/.ansible/roles/` by default
2. **`ansible-galaxy collection install`** — downloads a namespaced collection; modules accessed via FQCN
3. **`requirements.yml`** — the standard way to declare all project dependencies; commit this file to version control
4. **Version pinning** — always pin versions in `requirements.yml` for reproducible deployments
5. **FQCN** — use `namespace.collection.module` (e.g. `community.mysql.mysql_db`) to avoid module name conflicts
6. **Role defaults** — every role exposes variables in `defaults/main.yml`; override them in your `vars:` block
7. **`-p ./roles`** — install roles locally alongside the playbook to keep the project fully self-contained
