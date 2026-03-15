# Chapter 07 - Tags

Control which parts of your playbook run using tags.

## What You'll Learn

- Tagging tasks for selective execution
- Using `--tags` and `--skip-tags` from the CLI
- Special tags: `always` and `never`
- Tag inheritance (play, block, include)
- Practical deployment patterns with tags

---

## Quick Start

```bash
cd chapter-07-tags
ansible all -m ping
ansible-playbook 01-tag-basics.yml --list-tags
ansible-playbook 01-tag-basics.yml --tags "install"
```

---

## Playbooks

| # | Playbook | Concepts Covered |
|---|----------|------------------|
| 01 | tag-basics.yml | Basic tags, multiple tags per task, --tags, --skip-tags |
| 02 | always-never-tags.yml | `always` tag, `never` tag, dangerous task protection |
| 03 | tag-inheritance.yml | Play-level tags, block-level tags, untagged tasks |
| 04 | tags-practical.yml | Full deployment playbook with phased tags |

---

## Run the Playbooks

### Playbook 01: Tag Basics

```bash
# Run everything
ansible-playbook 01-tag-basics.yml

# Run only install tasks
ansible-playbook 01-tag-basics.yml --tags "install"

# Run only config tasks
ansible-playbook 01-tag-basics.yml --tags "config"

# Skip config, run everything else
ansible-playbook 01-tag-basics.yml --skip-tags "config"

# List all available tags
ansible-playbook 01-tag-basics.yml --list-tags
```

### Check the Status of Nginx
```bash
sudo systemctl status nginx
```

### Check the Status of Prometheous prometheus-node-exporter

```bash
systemctl list-unit-files | grep node-exporter

curl -I http://localhost:9100/metrics
```

**Covers:** Basic tagging, multiple tags on a task, CLI filtering

---

### Playbook 02: Always & Never Tags

```bash
# Run deploy tasks (+ 'always' tasks run automatically)
ansible-playbook 02-always-never-tags.yml --tags "health"

# Run the cleanup task (tagged 'never', must be explicitly called)
ansible-playbook 02-always-never-tags.yml --tags "cleanup"

# Skip even 'always' tasks
ansible-playbook 02-always-never-tags.yml --tags "deploy" --skip-tags "always"
```

**Covers:** `always` tag, `never` tag, protecting dangerous tasks

---

### Playbook 03: Tag Inheritance

```bash
# Run only the websetup play
ansible-playbook 03-tag-inheritance.yml --tags "websetup"

# Run only security block tasks
ansible-playbook 03-tag-inheritance.yml --tags "security"

# Run setup + security
ansible-playbook 03-tag-inheritance.yml --tags "setup,security"
```

**Covers:** Play-level tags, block-level tags, tag inheritance

---

### Playbook 04: Practical Deployment

```bash
# Full deployment (all phases)
ansible-playbook 04-tags-practical.yml

# Install packages only
ansible-playbook 04-tags-practical.yml --tags "install"

# Update configs without redeploying
ansible-playbook 04-tags-practical.yml --tags "config"

# Deploy code + restart services
ansible-playbook 04-tags-practical.yml --tags "deploy,service"

# Full deployment but skip firewall changes
ansible-playbook 04-tags-practical.yml --skip-tags "firewall"
```

**Covers:** Real-world phased deployment with tags

---

## Quick Reference

### Basic Tag Syntax

```yaml
tasks:
  - name: Install package
    apt:
      name: nginx
      state: present
    tags: install

  - name: Configure service
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    tags:
      - config
      - nginx
```

### CLI Options

| Option | Description | Example |
|--------|-------------|---------|
| `--tags` | Run only tasks with these tags | `--tags "install,config"` |
| `--skip-tags` | Skip tasks with these tags | `--skip-tags "firewall"` |
| `--list-tags` | Show all available tags | `--list-tags` |

---

### Special Tags

| Tag | Behavior | Override |
|-----|----------|----------|
| `always` | Runs every time, regardless of `--tags` filter | `--skip-tags "always"` |
| `never` | Never runs, unless explicitly requested | `--tags "the_other_tag"` |

```yaml
# Always runs (health checks, directory setup)
- name: Ensure app directory exists
  file:
    path: /opt/app
    state: directory
  tags: always

# Never runs unless explicitly called
- name: Drop and recreate database
  command: /opt/app/bin/reset-db
  tags:
    - never
    - reset_db
# Run with: ansible-playbook site.yml --tags "reset_db"
```

---

### Tag Inheritance

```yaml
# Play-level: all tasks inherit the tag
- name: Web server setup
  hosts: webservers
  tags: web
  tasks:
    - name: Install nginx    # inherits 'web' tag
    - name: Start nginx      # inherits 'web' tag

# Block-level: all tasks in block inherit the tag
- name: Server setup
  hosts: all
  tasks:
    - name: Security tasks
      tags: security
      block:
        - name: Disable root   # inherits 'security' tag
        - name: Set firewall    # inherits 'security' tag
```

---

## Tag Behavior Summary

```
┌──────────────────────────────────────────────────────────┐
│          ansible-playbook site.yml --tags "deploy"       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│   Task: Ensure directory   [tags: always]    ──► RUNS   │
│   Task: Install packages   [tags: install]   ──► SKIP   │
│   Task: Update config      [tags: config]    ──► SKIP   │
│   Task: Deploy code        [tags: deploy]    ──► RUNS   │
│   Task: Health check       [tags: always]    ──► RUNS   │
│   Task: Reset database     [tags: never]     ──► SKIP   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Common Patterns

### Pattern 1: Phased Deployment

```yaml
# Tag tasks by phase for granular control
tags: install    # Package installation
tags: config     # Configuration files
tags: deploy     # Code deployment
tags: service    # Service management
tags: firewall   # Network rules
```

```bash
# Day 1: Full setup
ansible-playbook site.yml

# Day 2: Config change only
ansible-playbook site.yml --tags "config"

# Day 3: Deploy new code + restart
ansible-playbook site.yml --tags "deploy,service"
```

### Pattern 2: Protect Dangerous Tasks

```yaml
# Tasks that should never run accidentally
- name: Wipe and rebuild database
  command: /opt/db/rebuild.sh
  tags:
    - never
    - rebuild_db
```

### Pattern 3: Always-Run Prerequisites

```yaml
# Ensure directories/users exist before any operation
- name: Create app user
  user:
    name: deploy
    system: true
  tags: always
```

---

## Key Takeaways

1. **`tags`** - Label tasks for selective execution
2. **`--tags`** - Run only matching tasks from CLI
3. **`--skip-tags`** - Exclude matching tasks from CLI
4. **`always`** - Task runs regardless of tag filters
5. **`never`** - Task is skipped unless explicitly included
6. **Inheritance** - Tags cascade from plays and blocks to child tasks
7. **Untagged tasks** - Run when no `--tags` filter is used, skipped when filter is active
