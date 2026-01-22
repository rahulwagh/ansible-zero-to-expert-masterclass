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
  }
  pre code {
    color: #ffffff !important;
    font-weight: 400;
    line-height: 1.4;
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
    font-size: 0.85em;
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
  .highest {
    background: #48bb78;
    color: white;
    padding: 2px 8px;
    border-radius: 4px;
  }
  .lowest {
    background: #fc8181;
    color: white;
    padding: 2px 8px;
    border-radius: 4px;
  }
---

# Chapter 03
# Variables 📦

### Mastering Data Management in Ansible

---

## What Are Variables?

**Variables** store values that can be reused throughout your playbooks.

```yaml
vars:
  http_port: 80
  app_name: "MyApp"

tasks:
  - name: Display port
    debug:
      msg: "Port is {{ http_port }}"
```

> Variables make playbooks **dynamic** and **reusable**

---

## Why Use Variables?

| Benefit | Description |
|---------|-------------|
| **Reusability** | Write once, use everywhere |
| **Flexibility** | Different values per environment |
| **Maintainability** | Change in one place |
| **Readability** | Self-documenting code |
| **Security** | Separate secrets from code |

---

## Variable Naming Rules

```
┌────────────────────────────────────────────────────────┐
│                   NAMING RULES                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│   ✅ VALID                    ❌ INVALID                │
│   ─────────                   ──────────                │
│   http_port                   http-port  (no hyphens)   │
│   app_name                    app name   (no spaces)    │
│   server1                     1server    (no start num) │
│   myApp                       my.app     (no dots)      │
│   _private                    class      (reserved)     │
│                                                         │
│   Must start with letter or underscore                  │
│   Can contain letters, numbers, underscores             │
│                                                         │
└────────────────────────────────────────────────────────┘
```

---

## Ways to Define Variables

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐  │
│   │    vars     │   │ vars_files  │   │ group_vars  │  │
│   │  (inline)   │   │  (files)    │   │ (directory) │  │
│   └─────────────┘   └─────────────┘   └─────────────┘  │
│                                                          │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐  │
│   │  host_vars  │   │  set_fact   │   │  extra vars │  │
│   │ (directory) │   │  (runtime)  │   │    (-e)     │  │
│   └─────────────┘   └─────────────┘   └─────────────┘  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 1. Inline Variables (vars)

### Define variables directly in playbook

```yaml
- name: Demo inline variables
  hosts: all
  vars:
    http_port: 80
    app_name: "MyWebApp"
    packages:
      - nginx
      - php
    config:
      timeout: 30
      retries: 3

  tasks:
    - debug:
        msg: "App: {{ app_name }} on port {{ http_port }}"
```

---

## Variable Data Types

```yaml
vars:
  # String
  app_name: "MyApp"

  # Number
  http_port: 80
  timeout: 30.5

  # Boolean
  debug_mode: true

  # List
  packages:
    - nginx
    - php
    - mysql

  # Dictionary
  database:
    host: localhost
    port: 3306
    name: mydb
```

---

## Accessing Variables

```yaml
tasks:
  # Simple variable
  - debug:
      msg: "{{ app_name }}"

  # List item (by index)
  - debug:
      msg: "{{ packages[0] }}"      # nginx

  # Dictionary (dot notation)
  - debug:
      msg: "{{ database.host }}"    # localhost

  # Dictionary (bracket notation)
  - debug:
      msg: "{{ database['port'] }}" # 3306

  # Loop through list
  - debug:
      msg: "Package: {{ item }}"
    loop: "{{ packages }}"
```

---

## 2. Variables from Files (vars_files)

### Keep variables in separate YAML files

```yaml
# playbook.yml
- name: Load external variables
  hosts: all
  vars_files:
    - vars/common.yml
    - vars/web_config.yml

  tasks:
    - debug:
        msg: "{{ app_name }} v{{ app_version }}"
```

```yaml
# vars/common.yml
app_name: "MyApplication"
app_version: "2.0.0"
```

---

## vars_files Benefits

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│   playbook.yml          vars/common.yml                  │
│   ┌──────────────┐      ┌──────────────────┐            │
│   │              │      │ app_name: MyApp  │            │
│   │  vars_files: │ ───► │ version: 2.0     │            │
│   │   - vars/    │      │ api_url: https://│            │
│   │     common   │      └──────────────────┘            │
│   │              │                                       │
│   │              │      vars/web_config.yml              │
│   │   - vars/    │      ┌──────────────────┐            │
│   │     web_cfg  │ ───► │ http_port: 80    │            │
│   │              │      │ doc_root: /var/  │            │
│   └──────────────┘      └──────────────────┘            │
│                                                          │
│   ✅ Separates config from logic                         │
│   ✅ Reusable across playbooks                           │
│   ✅ Easier to manage                                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Group Variables (group_vars/)

### Automatic loading based on group membership

```
chapter-03-variables/
├── inventory/
│   └── hosts.ini
├── group_vars/
│   ├── all.yml           ← All hosts
│   ├── webservers.yml    ← webservers group only
│   └── dbservers.yml     ← dbservers group only
└── playbook.yml
```

> Ansible automatically loads variables based on inventory groups!

---

## group_vars/all.yml

### Variables for ALL hosts

```yaml
# group_vars/all.yml
organization: "TechCorp Inc"
admin_email: "admin@techcorp.com"
timezone: "UTC"

common_packages:
  - vim
  - curl
  - htop

ntp_servers:
  - 0.pool.ntp.org
  - 1.pool.ntp.org
```

**Applied to:** Every host in inventory

---

## group_vars/webservers.yml

### Variables for webservers group only

```yaml
# group_vars/webservers.yml
http_port: 80
https_port: 443
document_root: /var/www/html

nginx_worker_processes: auto
nginx_worker_connections: 1024

web_packages:
  - nginx
  - php-fpm
```

**Applied to:** Only hosts in `[webservers]` group

---

## group_vars in Action

```
┌─────────────────────────────────────────────────────────┐
│                     INVENTORY                            │
│   [webservers]           [dbservers]                    │
│   server-1               server-3                        │
│   server-2                                               │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   GROUP_VARS LOADING                     │
│                                                          │
│   server-1, server-2:              server-3:            │
│   ┌────────────────────┐           ┌──────────────────┐ │
│   │ group_vars/all.yml │           │ group_vars/all   │ │
│   │         +          │           │        +         │ │
│   │ group_vars/        │           │ group_vars/      │ │
│   │   webservers.yml   │           │   dbservers.yml  │ │
│   └────────────────────┘           └──────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 4. Host Variables (host_vars/)

### Per-host variable overrides

```
chapter-03-variables/
├── host_vars/
│   ├── ansible-lab-server-1.yml   ← Specific to server-1
│   ├── ansible-lab-server-2.yml   ← Specific to server-2
│   └── ansible-lab-server-3.yml   ← Specific to server-3
```

```yaml
# host_vars/ansible-lab-server-1.yml
server_role: "primary_web"
http_port: 8080           # Overrides group_vars!
max_connections: 200
```

---

## host_vars Override Example

```
┌────────────────────────────────────────────────────────────┐
│                                                             │
│   group_vars/webservers.yml        host_vars/server-1.yml  │
│   ┌─────────────────────┐          ┌─────────────────────┐ │
│   │ http_port: 80       │          │ http_port: 8080     │ │
│   │ document_root: /var │          │ server_role: primary│ │
│   └─────────────────────┘          └─────────────────────┘ │
│                                                             │
│                    RESULT FOR server-1:                     │
│                    ┌─────────────────────┐                  │
│                    │ http_port: 8080  ◄── host_vars wins   │
│                    │ document_root: /var                   │
│                    │ server_role: primary                  │
│                    └─────────────────────┘                  │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

## Variable Precedence

### The Big Picture (Simplified)

```
┌─────────────────────────────────────────────────────────┐
│                 VARIABLE PRECEDENCE                      │
│              (Lowest → Highest Priority)                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   1. role defaults          ← Lowest                     │
│   2. inventory group_vars/all                            │
│   3. inventory group_vars/*                              │
│   4. inventory host_vars/*                               │
│   5. play vars                                           │
│   6. play vars_files                                     │
│   7. task vars                                           │
│   8. set_fact                                            │
│   9. extra vars (-e)        ← HIGHEST (always wins!)    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Precedence Visual

```
                    ┌───────────────────┐
                    │   EXTRA VARS -e   │  ◄── HIGHEST
                    │   (always wins)   │      PRIORITY
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │    set_fact       │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │    task vars      │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │    play vars      │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │    host_vars/*    │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │   group_vars/*    │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │  group_vars/all   │  ◄── LOWEST
                    └───────────────────┘      PRIORITY
```

---

## Precedence Example

```yaml
# group_vars/all.yml
http_port: 80                    # Level 2

# group_vars/webservers.yml
http_port: 8080                  # Level 3 (overrides all.yml)

# host_vars/server-1.yml
http_port: 9090                  # Level 4 (overrides group_vars)

# playbook.yml
vars:
  http_port: 3000                # Level 5 (overrides host_vars)

# Command line
# -e "http_port=4000"            # Level 9 (WINS!)
```

**Result:** `http_port = 4000`

---

## 5. Extra Variables (-e)

### Command-line overrides - HIGHEST precedence!

```bash
# Single variable
ansible-playbook site.yml -e "env=staging"

# Multiple variables
ansible-playbook site.yml -e "env=staging version=2.0"

# JSON format
ansible-playbook site.yml -e '{"env": "prod", "debug": true}'

# From file
ansible-playbook site.yml -e "@vars/production.yml"
```

> Extra vars **always win** - great for CI/CD!

---

## Extra Vars Use Cases

```
┌─────────────────────────────────────────────────────────┐
│                  EXTRA VARS USE CASES                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   🚀 CI/CD Deployments                                   │
│      ansible-playbook deploy.yml -e "version=2.5.0"     │
│                                                          │
│   🔧 Environment Selection                               │
│      ansible-playbook site.yml -e "env=production"      │
│                                                          │
│   🐛 Debug Mode                                          │
│      ansible-playbook site.yml -e "debug=true"          │
│                                                          │
│   👤 Runtime Parameters                                  │
│      ansible-playbook user.yml -e "username=john"       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 6. Register Variables

### Capture task output for later use

```yaml
tasks:
  - name: Get hostname
    command: hostname
    register: hostname_result

  - name: Display the hostname
    debug:
      msg: "Hostname is {{ hostname_result.stdout }}"

  - name: Check return code
    debug:
      msg: "Return code: {{ hostname_result.rc }}"
```

---

## Register Variable Structure

```yaml
# What register captures:
hostname_result:
  changed: false
  cmd: ["hostname"]
  rc: 0                    # Return code
  stdout: "server-1"       # Standard output
  stdout_lines: ["server-1"]
  stderr: ""               # Standard error
  stderr_lines: []
  start: "2024-01-15 10:00:00"
  end: "2024-01-15 10:00:00"
  delta: "0:00:00.005"
```

---

## Register with Conditionals

```yaml
tasks:
  - name: Check if nginx is installed
    command: which nginx
    register: nginx_check
    ignore_errors: true

  - name: Install nginx if missing
    apt:
      name: nginx
      state: present
    when: nginx_check.rc != 0

  - name: Nginx is already installed
    debug:
      msg: "Nginx found at {{ nginx_check.stdout }}"
    when: nginx_check.rc == 0
```

---

## 7. set_fact - Runtime Variables

### Create variables during playbook execution

```yaml
tasks:
  - name: Set a simple fact
    set_fact:
      my_app_path: "/opt/myapp"

  - name: Set fact based on condition
    set_fact:
      server_type: "{{ 'web' if 'webservers' in group_names else 'other' }}"

  - name: Set multiple facts
    set_fact:
      full_url: "https://{{ ansible_hostname }}:{{ http_port }}"
      deploy_time: "{{ ansible_date_time.iso8601 }}"
```

> set_fact variables persist across plays for the same host!

---

## 8. Ansible Facts

### System information gathered automatically

```yaml
- name: Show system facts
  hosts: all
  gather_facts: true      # Enable fact gathering

  tasks:
    - debug:
        msg: |
          OS: {{ ansible_distribution }}
          Version: {{ ansible_distribution_version }}
          IP: {{ ansible_default_ipv4.address }}
          Memory: {{ ansible_memtotal_mb }} MB
          CPUs: {{ ansible_processor_vcpus }}
```

---

## Useful Facts Reference

| Fact | Example Value |
|------|---------------|
| `ansible_hostname` | server-1 |
| `ansible_fqdn` | server-1.example.com |
| `ansible_distribution` | Ubuntu |
| `ansible_distribution_version` | 22.04 |
| `ansible_os_family` | Debian |
| `ansible_default_ipv4.address` | 10.0.0.5 |
| `ansible_memtotal_mb` | 4096 |
| `ansible_processor_vcpus` | 4 |

---

## View All Facts

```bash
# All facts
ansible all -m setup

# Filter specific facts
ansible all -m setup -a "filter=ansible_distribution*"

# Network facts only
ansible all -m setup -a "gather_subset=network"
```

---

## 9. Magic Variables

### Special variables provided by Ansible

```yaml
tasks:
  - debug:
      msg: |
        Host: {{ inventory_hostname }}
        Groups: {{ group_names | join(', ') }}
        All hosts: {{ groups['all'] | join(', ') }}
        Play hosts: {{ ansible_play_hosts | join(', ') }}
        Playbook dir: {{ playbook_dir }}
```

---

## Magic Variables Reference

| Variable | Description |
|----------|-------------|
| `inventory_hostname` | Current host name from inventory |
| `ansible_host` | IP/hostname to connect to |
| `group_names` | List of groups for current host |
| `groups` | Dict of all groups and their hosts |
| `hostvars` | Dict of vars for all hosts |
| `ansible_play_hosts` | Hosts in current play |
| `playbook_dir` | Directory of playbook |
| `inventory_dir` | Directory of inventory |

---

## hostvars - Access Other Hosts' Variables

```yaml
tasks:
  # Access variable from another host
  - debug:
      msg: "DB server port: {{ hostvars['db-server-1'].db_port }}"

  # Loop through all hosts
  - debug:
      msg: "{{ item }}: {{ hostvars[item].ansible_host }}"
    loop: "{{ groups['all'] }}"
```

---

## 10. Variable Scopes

```
┌─────────────────────────────────────────────────────────┐
│                   VARIABLE SCOPES                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   GLOBAL SCOPE                                           │
│   └── Set by: -e, config, environment                   │
│   └── Lifetime: Entire playbook run                     │
│                                                          │
│   PLAY SCOPE                                             │
│   └── Set by: vars, vars_files in play                  │
│   └── Lifetime: Current play only                       │
│                                                          │
│   HOST SCOPE                                             │
│   └── Set by: host_vars, group_vars, set_fact           │
│   └── Lifetime: Entire run (per host)                   │
│                                                          │
│   TASK SCOPE                                             │
│   └── Set by: vars on task                              │
│   └── Lifetime: Single task only                        │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Scope Example

```yaml
- name: Play 1
  hosts: all
  vars:
    play_var: "I exist only in Play 1"

  tasks:
    - set_fact:
        host_var: "I persist for this host"

- name: Play 2
  hosts: all
  tasks:
    - debug:
        msg: "{{ play_var }}"     # UNDEFINED!

    - debug:
        msg: "{{ host_var }}"     # Still works!
```

---

## Directory Structure Summary

```
chapter-03-variables/
├── ansible.cfg
├── inventory/
│   └── hosts.ini
│
├── group_vars/              ← Auto-loaded by group
│   ├── all.yml              ← All hosts
│   ├── webservers.yml       ← [webservers] group
│   ├── dbservers.yml        ← [dbservers] group
│   └── production.yml       ← [production] group
│
├── host_vars/               ← Auto-loaded by hostname
│   ├── server-1.yml
│   ├── server-2.yml
│   └── server-3.yml
│
├── vars/                    ← Loaded via vars_files
│   ├── common.yml
│   └── web_config.yml
│
└── playbooks...
```

---

## Best Practices

✅ **DO:**
- Use `group_vars/all.yml` for common defaults
- Use `host_vars/` only for true host-specific values
- Use descriptive variable names (`http_port` not `p`)
- Use `-e` for CI/CD and deployment parameters
- Keep sensitive data in Ansible Vault (next chapter!)

❌ **DON'T:**
- Hardcode values in playbooks
- Override variables unnecessarily
- Store passwords in plain text
- Use complex variable names with special characters

---

## Quick Reference

| Method | Location | Auto-Loaded | Precedence |
|--------|----------|-------------|------------|
| `vars` | playbook | - | Medium |
| `vars_files` | playbook | - | Medium |
| `group_vars/` | directory | ✅ | Low-Medium |
| `host_vars/` | directory | ✅ | Medium |
| `set_fact` | task | - | High |
| `-e` | command | - | **Highest** |

---

## Hands-on Exercises

```bash
# 1. Run inline variables playbook
ansible-playbook 01-vars-inline.yml

# 2. Test vars_files
ansible-playbook 02-vars-files.yml

# 3. See group_vars in action
ansible-playbook 03-group-vars.yml

# 4. Demonstrate host_vars override
ansible-playbook 04-host-vars.yml

# 5. Test precedence with -e
ansible-playbook 05-variable-precedence.yml \
  -e "precedence_test='CLI wins!'"
```

---

## Summary

### What We Learned:

- ✅ Inline variables with `vars`
- ✅ External files with `vars_files`
- ✅ Auto-loaded `group_vars/` and `host_vars/`
- ✅ Variable precedence (22 levels!)
- ✅ Extra vars `-e` (highest precedence)
- ✅ Register task output
- ✅ Ansible facts
- ✅ Magic variables
- ✅ Variable scopes

---

## Next Chapter

# Chapter 04
## Ansible Vault

- Encrypting sensitive data
- Creating encrypted files
- Using vault passwords
- Best practices for secrets management

---

# Thank You! 🎉

### Questions?

**Key Takeaway:**
> "Extra vars (-e) always win!"

**Resources:**
- 📚 [docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)

---
