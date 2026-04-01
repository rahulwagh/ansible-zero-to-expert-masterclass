---
marp: true
theme: default
paginate: true
backgroundColor: #ffffff
color: #333333
style: |
  section {
    font-family: 'Segoe UI', Arial, sans-serif;
    background: linear-gradient(135deg, #f5f7fa 0%, #e4e8ec 100%);
    padding: 40px 50px 60px 50px;
  }
  h1 {
    color: #e94560;
    font-weight: 700;
  }
  h2 {
    color: #ffffff;
    background: linear-gradient(90deg, #e94560 0%, #0f3460 100%);
    padding: 10px 20px;
    border-radius: 5px;
    font-size: 1.3em;
  }
  h3 {
    color: #0f3460;
  }
  code {
    background: #1a1a2e;
    color: #ffffff !important;
    padding: 2px 8px;
    border-radius: 4px;
  }
  pre {
    background: #1a1a2e;
    border-radius: 10px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
    font-size: 0.75em;
  }
  pre code {
    color: #ffffff !important;
    font-weight: 400;
    line-height: 1.3;
  }
  pre code span {
    color: #ffffff !important;
  }
  code span {
    color: #ffffff !important;
  }
  .hljs-attr, .hljs-attribute {
    color: #7dd3fc !important;
  }
  .hljs-string {
    color: #86efac !important;
  }
  .hljs-number {
    color: #fca5a5 !important;
  }
  .hljs-keyword {
    color: #c4b5fd !important;
  }
  .hljs-comment {
    color: #9ca3af !important;
  }
  .hljs-literal {
    color: #fdba74 !important;
  }
  table {
    font-size: 0.8em;
    width: 100%;
  }
  th {
    background: #e94560;
    color: #ffffff;
  }
  td {
    background: #f8f9fa;
  }
  tr:nth-child(even) td {
    background: #e9ecef;
  }
  strong {
    color: #e94560;
  }
  blockquote {
    border-left: 4px solid #e94560;
    background: #f8f9fa;
    padding: 10px 20px;
    font-style: italic;
  }
---

# Chapter 10
# Ansible Galaxy

### Use Community Roles & Collections to Build Real Infrastructure

---

## What You'll Learn

- What Ansible Galaxy is and why it matters
- Installing roles with `ansible-galaxy role install`
- Installing collections with `ansible-galaxy collection install`
- Using `requirements.yml` to declare and pin all dependencies
- Fully Qualified Collection Names (FQCN)
- Passing variables to override role defaults
- Real-world: deploying a LAMP stack using only Galaxy roles and collections

---

## What Is Ansible Galaxy?

**Ansible Galaxy** is the official hub for sharing Ansible content.

```
                    ┌──────────────────────────────────────┐
                    │          galaxy.ansible.com          │
                    │  Roles          Collections          │
                    │  geerlingguy.*  community.general    │
                    │  dev-sec.*      community.mysql       │
                    │  ...            ansible.posix  ...   │
                    └──────────────────────────────────────┘
                                  │
          ansible-galaxy role install / collection install
                                  │
                    ┌─────────────▼────────────────────────┐
                    │         Your Control Node            │
                    │  ~/.ansible/roles/                   │
                    │  ~/.ansible/collections/             │
                    └──────────────────────────────────────┘
```

> Stop writing everything from scratch — reuse battle-tested community content

---

## Roles vs Collections

| Feature | Role | Collection |
|---------|------|------------|
| **Contains** | tasks, handlers, vars, templates | modules, plugins, roles, docs |
| **Install** | `ansible-galaxy role install` | `ansible-galaxy collection install` |
| **Reference** | `roles:` or `include_role:` | FQCN: `namespace.collection.module` |
| **Installed to** | `~/.ansible/roles/` | `~/.ansible/collections/` |
| **Version pin** | `version: "1.0.0"` | `version: "1.0.0"` |

> A **role** automates a single concern (e.g. install nginx). A **collection** bundles many modules, plugins, and roles under one namespace.

---

## Installing Roles

```bash
# Install a role by name (latest version)
ansible-galaxy role install geerlingguy.nginx

# Install a specific version
ansible-galaxy role install geerlingguy.nginx,3.1.0

# Install multiple roles at once
ansible-galaxy role install geerlingguy.nginx geerlingguy.git

# Install to a local ./roles directory (project-scoped)
ansible-galaxy role install geerlingguy.nginx -p ./roles

# List installed roles
ansible-galaxy role list

# Remove a role
ansible-galaxy role remove geerlingguy.nginx

# Show role info and available variables
ansible-galaxy role info geerlingguy.nginx
```

---

## Using a Role in a Playbook

```yaml
# Basic role usage
- name: Deploy Nginx
  hosts: webservers
  become: true

  roles:
    - geerlingguy.nginx
```

```yaml
# Multiple roles — applied in order
- name: Deploy web stack
  hosts: webservers
  become: true

  roles:
    - geerlingguy.git      # applied first
    - geerlingguy.nginx    # applied second
```

> Roles run in the order listed — manage dependencies carefully

---

## Installing Collections

```bash
# Install a collection
ansible-galaxy collection install community.general

# Install a specific version
ansible-galaxy collection install community.mysql:3.9.0

# Install multiple collections at once
ansible-galaxy collection install community.general community.mysql ansible.posix

# List installed collections
ansible-galaxy collection list

# Show collection info
ansible-galaxy collection list community.general

# Upgrade a collection to the latest version
ansible-galaxy collection install community.general --upgrade
```

---

## Fully Qualified Collection Name (FQCN)

A **FQCN** uniquely identifies a module: `namespace.collection.module`

```yaml
# Short name — works but can clash with another collection's module
- copy:
    src: file.txt
    dest: /tmp/file.txt

# FQCN for a built-in module — unambiguous, best practice
- ansible.builtin.copy:
    src: file.txt
    dest: /tmp/file.txt

# Community collection module — FQCN is required
- community.mysql.mysql_db:
    name: appdb
    state: present
    login_unix_socket: /var/run/mysqld/mysqld.sock

# POSIX collection module
- ansible.posix.firewalld:
    service: http
    permanent: true
    state: enabled
    immediate: true
```

---

## Why Always Use FQCN?

```
  Without FQCN:               With FQCN:
  ┌─────────────┐             ┌────────────────────────────┐
  │   - copy:   │  ambiguous  │ - ansible.builtin.copy:    │
  │             │    ──►      │                            │
  │             │  which one? │   namespace.collection     │
  └─────────────┘             │   clearly identified       │
                              └────────────────────────────┘
```

| Namespace | Collection | Example Module |
|-----------|-----------|----------------|
| `ansible` | `builtin` | `ansible.builtin.copy` |
| `ansible` | `posix` | `ansible.posix.firewalld` |
| `community` | `general` | `community.general.slack` |
| `community` | `mysql` | `community.mysql.mysql_db` |

> Always use FQCN inside roles and collections — it prevents silent module shadowing

---

## Overriding Role Defaults

Every role exposes configurable variables in `defaults/main.yml`.

```bash
# Inspect a role's available variables
cat ~/.ansible/roles/geerlingguy.nginx/defaults/main.yml
```

```yaml
- name: Deploy Nginx with custom config
  hosts: webservers
  become: true

  vars:
    nginx_listen_port: 8080          # overrides default of 80
    nginx_remove_default_vhost: true # remove default vhost

  roles:
    - geerlingguy.nginx
```

> **Rule:** vars in your playbook always win over role `defaults/main.yml`

---

## Pre and Post Tasks Around Roles

```yaml
- name: Nginx with pre/post tasks
  hosts: webservers
  become: true

  pre_tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"

  roles:
    - geerlingguy.nginx

  post_tasks:
    - name: Verify Nginx is running
      ansible.builtin.service:
        name: nginx
        state: started
      register: nginx_status

    - name: Print Nginx status
      ansible.builtin.debug:
        msg: "Nginx is {{ nginx_status.state }}"
```

---

## requirements.yml — What and Why

`requirements.yml` is the standard way to declare **all project dependencies** in one file.

```
  Without requirements.yml:             With requirements.yml:
  ┌──────────────────────────┐          ┌──────────────────────────────────┐
  │ README says: "install    │          │ ansible-galaxy install           │
  │ these 5 roles manually"  │  ──►     │   -r requirements.yml            │
  │ ...team forgets one...   │          │                                  │
  │ ...prod breaks           │          │ All dependencies installed in    │
  └──────────────────────────┘          │ one command, correct versions    │
                                        └──────────────────────────────────┘
```

> Commit `requirements.yml` to version control — it is the dependency manifest for your project

---

## requirements.yml — Structure

```yaml
---
roles:
  # Install by role name (latest version)
  - name: geerlingguy.nginx

  # Install a specific version
  - name: geerlingguy.git
    version: "3.0.0"

  # Install from a GitHub repository
  - name: my_custom_nginx
    src: https://github.com/geerlingguy/ansible-role-nginx
    version: master
    scm: git

collections:
  # Install by namespace.collection (latest version)
  - name: community.general

  # Install a specific version
  - name: community.mysql
    version: "3.9.0"

  # Install from Ansible Galaxy (explicit source)
  - name: ansible.posix
    source: https://galaxy.ansible.com
```

---

## Installing from requirements.yml

```bash
# Install ALL roles and collections declared in requirements.yml
ansible-galaxy install -r requirements.yml

# Install to a local ./roles directory (keeps project self-contained)
ansible-galaxy install -r requirements.yml -p ./roles

# Install collections only
ansible-galaxy collection install -r requirements.yml

# Force re-download / update all dependencies
ansible-galaxy install -r requirements.yml --force

# Verify what is installed after
ansible-galaxy role list
ansible-galaxy collection list
```

> Always use `-r requirements.yml` in CI/CD pipelines before running playbooks

---

## Where Are Roles & Collections Installed?

```bash
# Role search paths (highest → lowest priority)
./roles/                              # project-local (highest)
~/.ansible/roles/                     # user-level
/usr/share/ansible/roles/             # system-level

# Collection install path
~/.ansible/collections/ansible_collections/

# Override role path in ansible.cfg
[defaults]
roles_path = ./roles:~/.ansible/roles
```

```ini
# ansible.cfg — keep roles alongside the playbook
[defaults]
roles_path        = ./roles
collections_paths = ./collections:~/.ansible/collections
```

> Use `./roles` for project-local installs — makes the repo fully self-contained

---

## Galaxy CLI Quick Reference — Roles

```bash
# Install
ansible-galaxy role install geerlingguy.nginx
ansible-galaxy role install geerlingguy.nginx,3.1.0     # pin version
ansible-galaxy role install -r requirements.yml          # from file

# Inspect
ansible-galaxy role list                                 # list installed
ansible-galaxy role info geerlingguy.nginx               # details + vars
ansible-galaxy search nginx --author geerlingguy        # search Galaxy

# Manage
ansible-galaxy role remove geerlingguy.nginx             # uninstall
ansible-galaxy role install -r requirements.yml --force  # update
```

---

## Galaxy CLI Quick Reference — Collections

```bash
# Install
ansible-galaxy collection install community.general
ansible-galaxy collection install community.mysql:3.9.0  # pin version
ansible-galaxy collection install -r requirements.yml    # from file

# Inspect
ansible-galaxy collection list                           # list installed
ansible-galaxy collection list community.general         # filter by ns

# Manage
ansible-galaxy collection install community.general --upgrade  # update
```

---

## Practical: LAMP Stack with Galaxy

Deploy a full **Linux + Nginx + MySQL + PHP** stack using only Galaxy roles and collections.

```
  requirements.yml
  ├── roles:
  │   ├── geerlingguy.nginx    ──► Play 1: web servers
  │   ├── geerlingguy.php      ──► Play 1: web servers
  │   └── geerlingguy.mysql    ──► Play 2: db servers
  └── collections:
      └── ansible.posix        ──► Play 3: firewall (all servers)
```

```bash
# Step 1: install all dependencies
ansible-galaxy install -r requirements.yml

# Step 2: dry-run
ansible-playbook 04-galaxy-practical.yml --check --diff

# Step 3: deploy
ansible-playbook 04-galaxy-practical.yml
```

---

## Practical: Play 1 — Nginx + PHP

```yaml
- name: "Play 1: Deploy Nginx and PHP on web servers"
  hosts: webservers
  become: true

  vars:
    nginx_listen_port: 80
    nginx_remove_default_vhost: true
    php_packages:
      - php8.1
      - php8.1-fpm
      - php8.1-mysql

  roles:
    - geerlingguy.nginx
    - geerlingguy.php

  post_tasks:
    - name: Create web root directory
      ansible.builtin.file:
        path: /var/www/myapp
        state: directory
        owner: www-data
        mode: "0755"
```

---

## Practical: Play 2 — MySQL

```yaml
- name: "Play 2: Deploy MySQL on database servers"
  hosts: dbservers
  become: true

  vars:
    mysql_root_password: "R00tSecure!2024"
    mysql_databases:
      - name: appdb
        encoding: utf8mb4
        collation: utf8mb4_unicode_ci
    mysql_users:
      - name: appuser
        host: "%"
        password: "AppSecure!2024"
        priv: "appdb.*:ALL"

  roles:
    - geerlingguy.mysql

  post_tasks:
    - name: Confirm MySQL service state
      ansible.builtin.debug:
        msg: "MySQL is running"
```

---

## Practical: Play 3 — Firewall

```yaml
- name: "Play 3: Configure firewall on all servers"
  hosts: production
  become: true

  tasks:
    - name: Allow SSH
      ansible.posix.firewalld:
        service: ssh
        permanent: true
        state: enabled
        immediate: true

    - name: Allow HTTP on webservers
      ansible.posix.firewalld:
        service: http
        permanent: true
        state: enabled
        immediate: true
      when: "'webservers' in group_names"

    - name: Allow MySQL on database servers
      ansible.posix.firewalld:
        port: "3306/tcp"
        permanent: true
        state: enabled
        immediate: true
      when: "'dbservers' in group_names"
```

---

## Common Mistakes

### Mistake 1: Using a role before installing it

```bash
# ❌ Running a playbook without installing the role first
ansible-playbook site.yml
# ERROR: the role 'geerlingguy.nginx' was not found

# ✅ Always install first
ansible-galaxy install -r requirements.yml
ansible-playbook site.yml
```

### Mistake 2: Not pinning versions in requirements.yml

```yaml
# ❌ Latest version — playbook can break when role is updated
- name: geerlingguy.nginx

# ✅ Pinned version — reproducible deployments
- name: geerlingguy.nginx
  version: "3.1.0"
```

---

## Common Mistakes (continued)

### Mistake 3: Short module name inside a collection

```yaml
# ❌ Ambiguous — could match multiple collections
- copy:
    src: file.txt
    dest: /tmp/file.txt

# ✅ FQCN — unambiguous, always use inside roles/collections
- ansible.builtin.copy:
    src: file.txt
    dest: /tmp/file.txt
```

### Mistake 4: Not committing requirements.yml

```bash
# ❌ Galaxy roles installed manually, not tracked anywhere
# ✅ Commit requirements.yml — it is your dependency manifest
git add requirements.yml
git commit -m "pin Galaxy role and collection versions"
```

---

## Best Practices

| Practice | Why |
|----------|-----|
| Always use `requirements.yml` | One command installs all dependencies |
| Pin versions in `requirements.yml` | Reproducible, predictable deployments |
| Always use FQCN | Prevents silent module name conflicts |
| Install to `./roles` with `-p` | Project self-contained, no global state |
| Commit `requirements.yml` | Dependency manifest lives with the code |
| Inspect `defaults/main.yml` first | Know what variables you can override |
| Run `--check --diff` before prod | Preview what Galaxy roles will change |

---

## Hands-on Exercises

```bash
cd chapter-10-ansible-galaxy

# Install a role and run it
ansible-galaxy role install geerlingguy.nginx geerlingguy.git
ansible-playbook 01-install-role.yml

# Install collections and use FQCN
ansible-galaxy collection install community.general community.mysql ansible.posix
ansible-playbook 02-install-collection.yml --check

# Install everything via requirements.yml
ansible-galaxy install -r 03-requirements.yml -p ./roles

# Full LAMP stack deployment (dry-run first)
ansible-galaxy install -r requirements.yml
ansible-playbook 04-galaxy-practical.yml --check --diff
ansible-playbook 04-galaxy-practical.yml
```

---

## Quick Reference

```bash
# Roles
ansible-galaxy role install <author>.<role>           # install
ansible-galaxy role install <author>.<role>,<version> # pin version
ansible-galaxy role list                              # list installed
ansible-galaxy role info  <author>.<role>             # details

# Collections
ansible-galaxy collection install <ns>.<col>          # install
ansible-galaxy collection install <ns>.<col>:<ver>    # pin version
ansible-galaxy collection list                        # list installed

# From file
ansible-galaxy install -r requirements.yml            # roles + collections
ansible-galaxy install -r requirements.yml -p ./roles # local install
ansible-galaxy install -r requirements.yml --force    # force update
```

---

## Key Takeaways

| Concept | Description |
|---------|-------------|
| `ansible-galaxy role install` | Downloads a role into `~/.ansible/roles/` by default |
| `ansible-galaxy collection install` | Downloads a namespaced collection; modules via FQCN |
| `requirements.yml` | Declare all project dependencies; commit to version control |
| Version pinning | Always pin versions for reproducible deployments |
| FQCN | `namespace.collection.module` — prevents module name conflicts |
| Role defaults | Override any `defaults/main.yml` variable in your `vars:` block |
| `-p ./roles` | Install roles locally to keep the project self-contained |

---

## Next Chapter

# Chapter 11
## Ansible Vault

- Encrypting sensitive data with `ansible-vault`
- Encrypting files, strings, and variables
- Using vault in playbooks and inventory
- Vault password files and multiple vault IDs

---

# Thank You!

### Questions?

**Key Takeaway:**
> "Never write what Galaxy already wrote — install, pin, and reuse community roles and collections!"

**Resources:**
- [Ansible Galaxy](https://galaxy.ansible.com)
- [ansible-galaxy CLI docs](https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html)
- [Using roles guide](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)
- [Using collections guide](https://docs.ansible.com/ansible/latest/collections_guide/index.html)

---
