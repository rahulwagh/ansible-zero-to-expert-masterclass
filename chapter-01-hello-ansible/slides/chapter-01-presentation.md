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
    background: #2d3748;
    color: #f8f8f2;
    padding: 2px 8px;
    border-radius: 4px;
  }
  pre {
    background: #282a36;
    border-radius: 10px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  }
  pre code {
    color: #f8f8f2;
    font-weight: 400;
    line-height: 1.5;
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
  a {
    color: #0f3460;
  }
---

# Chapter 01
# Hello Ansible 🚀

### Your First Steps into Infrastructure Automation

---

## What is Ansible?

**Ansible** is an open-source automation tool for:

- ⚙️ **Configuration Management**
- 🚀 **Application Deployment**
- 📦 **Provisioning**
- 🔄 **Orchestration**

> "Simple, Agentless, Powerful"

---

## Why Choose Ansible?

| Feature | Benefit |
|---------|---------|
| **Agentless** | No software to install on managed nodes |
| **SSH-based** | Uses existing SSH infrastructure |
| **YAML Syntax** | Human-readable, easy to learn |
| **Idempotent** | Safe to run multiple times |
| **Push-based** | You control when changes happen |
| **Large Community** | 1000s of modules available |

---

## Ansible vs Others

| Tool | Agent | Language | Learning Curve |
|------|-------|----------|----------------|
| **Ansible** | ❌ No | YAML | Easy |
| Puppet | ✅ Yes | DSL | Medium |
| Chef | ✅ Yes | Ruby | Hard |
| SaltStack | Optional | YAML | Medium |

---

## Ansible Architecture

```
┌─────────────────────────────────────────────────────┐
│              CONTROL NODE (Your Machine)             │
│  ┌─────────────┐  ┌──────────┐  ┌──────────────┐   │
│  │  Playbooks  │  │ Inventory │  │ ansible.cfg  │   │
│  └─────────────┘  └──────────┘  └──────────────┘   │
└───────────────────────┬─────────────────────────────┘
                        │ SSH
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │ Server 1│     │ Server 2│     │ Server 3│
   │ (Web)   │     │ (Web)   │     │  (DB)   │
   └─────────┘     └─────────┘     └─────────┘
              MANAGED NODES
```

---

## Key Components

| Component | Description |
|-----------|-------------|
| **Control Node** | Machine where Ansible is installed |
| **Managed Nodes** | Servers you want to automate |
| **Inventory** | List of managed nodes |
| **Playbook** | YAML file with automation tasks |
| **Module** | Unit of work (ping, copy, apt, etc.) |
| **Task** | Single action using a module |

---

## Installation

### macOS
```bash
brew install ansible
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install ansible
```

### Verify Installation
```bash
ansible --version
```

---

## Project Structure

```
chapter-01-hello-ansible/
│
├── ansible.cfg          # Configuration
├── inventory            # Host list
├── 01-ping-playbook.yml
├── 02-hello-world-playbook.yml
├── 03-gather-facts-playbook.yml
├── 04-dynamic-host-playbook.yml
└── README.md
```

---

## ansible.cfg Explained

```ini
[defaults]
inventory = inventory
host_key_checking = False
retry_files_enabled = False
```

| Setting | Purpose |
|---------|---------|
| `inventory` | Default inventory file path |
| `host_key_checking` | Skip SSH key verification (lab only!) |
| `retry_files_enabled` | Don't create .retry files |

---

## Inventory File

```ini
[ansible_lab_servers]
ansible-lab-server-1 ansible_host=34.2.48.253

[ansible_lab_servers:vars]
ansible_user=ansible
ansible_ssh_private_key_file=/path/to/key
ansible_python_interpreter=/usr/bin/python3
```

- **[group_name]** - Define a group
- **[group:vars]** - Variables for all hosts in group

---

## Ad-hoc Commands

Quick one-liner commands without playbooks:

```bash
# Ping all hosts
ansible all -m ping

# Run shell command
ansible all -m shell -a "uptime"

# Check disk space
ansible all -m command -a "df -h"

# Install a package
ansible all -m apt -a "name=nginx state=present" --become
```

---

## Ad-hoc Command Structure

```bash
ansible <pattern> -m <module> -a "<arguments>"
```

| Part | Description |
|------|-------------|
| `<pattern>` | Which hosts (all, webservers, server1) |
| `-m <module>` | Which module to use |
| `-a "<args>"` | Module arguments |
| `--become` | Run with sudo |
| `-i inventory` | Specify inventory file |

---

## Your First Playbook

### 01-ping-playbook.yml

```yaml
---
- name: Ping all hosts
  hosts: all
  gather_facts: false

  tasks:
    - name: Ping the server
      ansible.builtin.ping:
```

### Run it:
```bash
ansible-playbook 01-ping-playbook.yml
```

---

## Playbook Structure

```yaml
---                          # YAML start
- name: Play description     # Play name
  hosts: all                 # Target hosts
  gather_facts: false        # Skip fact gathering

  tasks:                     # List of tasks
    - name: Task description # Task name
      ansible.builtin.ping:  # Module to use
```

---

## Debug Module

### 02-hello-world-playbook.yml

```yaml
---
- name: Hello World Example
  hosts: all
  gather_facts: false

  tasks:
    - name: Print Hello World message
      ansible.builtin.debug:
        msg: "Hello World from Ansible!"

    - name: Print inventory hostname
      ansible.builtin.debug:
        msg: "Running on {{ inventory_hostname }}"
```

---

## Debug Module Output

```
TASK [Print Hello World message] **************
ok: [ansible-lab-server-1] => {
    "msg": "Hello World from Ansible!"
}

TASK [Print inventory hostname] ***************
ok: [ansible-lab-server-1] => {
    "msg": "Running on ansible-lab-server-1"
}
```

---

## Gather Facts

### 03-gather-facts-playbook.yml

```yaml
---
- name: Gather and Display System Facts
  hosts: all
  gather_facts: true    # Collect system info

  tasks:
    - name: Display OS Distribution
      ansible.builtin.debug:
        msg: "OS: {{ ansible_distribution }}"

    - name: Display IP Address
      ansible.builtin.debug:
        msg: "IP: {{ ansible_default_ipv4.address }}"
```

---

## What are Facts?

System information automatically collected by Ansible:

| Fact | Example Value |
|------|---------------|
| `ansible_distribution` | Ubuntu |
| `ansible_distribution_version` | 22.04 |
| `ansible_hostname` | ansible-lab-server-1 |
| `ansible_default_ipv4.address` | 10.0.0.5 |
| `ansible_memtotal_mb` | 1024 |
| `ansible_processor_cores` | 2 |

---

## View All Facts

```bash
# Ad-hoc command to see all facts
ansible all -m setup

# Filter specific facts
ansible all -m setup -a "filter=ansible_distribution*"
```

---

## Extra Variables (-e)

### 04-dynamic-host-playbook.yml

```yaml
---
- name: Run tasks on dynamically specified host
  hosts: "{{ target_host }}"
  gather_facts: true

  tasks:
    - name: Print the target host
      ansible.builtin.debug:
        msg: "Running on host: {{ target_host }}"
```

### Run it:
```bash
ansible-playbook 04-dynamic-host-playbook.yml \
  -i "34.2.48.253," \
  -e "target_host=34.2.48.253"
```

---

## Playbook Execution Flow

```
┌─────────────────────────────────────┐
│  1. Parse playbook (YAML)           │
├─────────────────────────────────────┤
│  2. Load inventory                  │
├─────────────────────────────────────┤
│  3. Gather facts (if enabled)       │
├─────────────────────────────────────┤
│  4. Execute tasks (in order)        │
├─────────────────────────────────────┤
│  5. Display results (PLAY RECAP)    │
└─────────────────────────────────────┘
```

---

## Understanding Output

```
PLAY [Ping all hosts] ********************************************

TASK [Ping the server] *******************************************
ok: [ansible-lab-server-1]

PLAY RECAP *******************************************************
ansible-lab-server-1  : ok=1  changed=0  unreachable=0  failed=0
```

| Status | Meaning |
|--------|---------|
| **ok** | Task completed, no changes |
| **changed** | Task made changes |
| **unreachable** | Cannot connect to host |
| **failed** | Task failed |

---

## Verbose Mode

Add `-v` flags for more details:

```bash
# Level 1 - Task results
ansible-playbook playbook.yml -v

# Level 2 - Task input/output
ansible-playbook playbook.yml -vv

# Level 3 - Connection debugging
ansible-playbook playbook.yml -vvv

# Level 4 - Everything (including SSH)
ansible-playbook playbook.yml -vvvv
```

---

## Check Mode (Dry Run)

Test without making changes:

```bash
ansible-playbook playbook.yml --check
```

### Diff Mode
See what would change:

```bash
ansible-playbook playbook.yml --check --diff
```

---

## Common Modules

| Module | Purpose | Example |
|--------|---------|---------|
| `ping` | Test connectivity | `ansible.builtin.ping:` |
| `debug` | Print messages | `msg: "Hello"` |
| `command` | Run commands | `cmd: uptime` |
| `shell` | Run shell commands | `cmd: "echo $HOME"` |
| `copy` | Copy files | `src: file dest: /tmp/` |
| `apt` | Manage packages | `name: nginx state: present` |

---

## Best Practices

✅ **DO:**
- Use meaningful names for plays and tasks
- Keep playbooks simple and focused
- Use `ansible.builtin.` prefix for modules
- Test with `--check` before running

❌ **DON'T:**
- Disable `host_key_checking` in production
- Hardcode passwords in playbooks
- Skip task names
- Ignore errors without handling them

---

## Hands-on Exercise

1. **Ping all hosts**
   ```bash
   ansible all -m ping
   ```

2. **Run the ping playbook**
   ```bash
   ansible-playbook 01-ping-playbook.yml
   ```

3. **Check system facts**
   ```bash
   ansible-playbook 03-gather-facts-playbook.yml
   ```

---

## Summary

### What We Learned:

- ✅ What Ansible is and why use it
- ✅ Ansible architecture (Control Node → Managed Nodes)
- ✅ ansible.cfg configuration
- ✅ Inventory file structure
- ✅ Ad-hoc commands
- ✅ Playbook structure (plays, tasks, modules)
- ✅ Debug and Ping modules
- ✅ Gather facts
- ✅ Extra variables with `-e`

---

## Next Chapter

# Chapter 02
## Inventory Deep Dive

- Static inventory formats (INI & YAML)
- Groups and nested groups
- Host patterns
- Group and host variables

---

# Thank You! 🎉

### Questions?

**Resources:**
- 📚 [docs.ansible.com](https://docs.ansible.com)
- 💻 [github.com/ansible](https://github.com/ansible)

---
