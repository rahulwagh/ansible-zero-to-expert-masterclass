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

# Chapter 07
# Tags

### Run Only What You Need

---

## What You'll Learn

- Tagging tasks for selective execution
- `--tags` and `--skip-tags` CLI options
- Special tags: `always` and `never`
- Tag inheritance (play-level, block-level)
- Practical deployment patterns

---

## What Are Tags?

**Tags** are labels on tasks that let you run or skip specific parts of a playbook.

```yaml
tasks:
  - name: Install nginx
    apt: name=nginx state=present
    tags: install              # label this task

  - name: Configure nginx
    template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf
    tags: config               # label this task
```

```bash
# Run ONLY install tasks
ansible-playbook site.yml --tags "install"
```

---

## Why Use Tags?

| Scenario | Without Tags | With Tags |
|----------|-------------|-----------|
| Config change only | Run entire playbook | `--tags "config"` |
| Debug one phase | Comment out tasks | `--tags "deploy"` |
| Skip slow tasks | Edit playbook | `--skip-tags "install"` |

> Tags give you **surgical control** without editing playbooks

---

## Basic Tag Syntax

```yaml
tasks:
  # Single tag
  - name: Install packages
    apt: name=nginx state=present
    tags: install

  # Multiple tags on one task
  - name: Install monitoring agent
    apt: name=prometheus-node-exporter state=present
    tags:
      - install
      - monitoring
```

---

## CLI Options

| Option | What It Does |
|--------|-------------|
| `--tags "install"` | Run only tasks tagged `install` |
| `--tags "install,config"` | Run tasks tagged `install` OR `config` |
| `--skip-tags "firewall"` | Run everything EXCEPT `firewall` tasks |
| `--list-tags` | Show all available tags (dry run) |

```bash
# Examples
ansible-playbook site.yml --tags "config"
ansible-playbook site.yml --skip-tags "firewall"
ansible-playbook site.yml --list-tags
```

---

## Tag Behavior Visual

```
   ansible-playbook site.yml --tags "deploy"

   Task: Install packages   [tags: install]   --> SKIP
   Task: Update config      [tags: config]    --> SKIP
   Task: Deploy code        [tags: deploy]    --> RUNS
   Task: Restart service    [tags: service]   --> SKIP
   Task: No tags            []                --> SKIP
```

> **Untagged tasks are skipped** when `--tags` is used

---

## Special Tag: always

Tasks tagged `always` run **every time**, regardless of `--tags` filter.

```yaml
tasks:
  - name: Ensure deploy directory exists
    file:
      path: /opt/app
      state: directory
    tags: always           # always runs!

  - name: Deploy application
    copy:
      src: release.tar.gz
      dest: /opt/app/
    tags: deploy
```

```bash
ansible-playbook site.yml --tags "deploy"
# Both tasks run!
```

---

## always - Use Cases

| Use Case | Example |
|----------|---------|
| **Prerequisites** | Ensure directories/users exist |
| **Health checks** | Verify service after any operation |
| **Logging** | Record what ran and when |

```yaml
- name: Check app health
  uri:
    url: "http://localhost:8080/health"
    status_code: 200
  tags: always
```

> Override with `--skip-tags "always"` if needed

---

## Special Tag: never

Tasks tagged `never` are **skipped by default**. Run them only when explicitly requested.

```yaml
tasks:
  - name: Normal deployment
    copy: src=app/ dest=/opt/app/
    tags: deploy

  - name: Reset database to factory defaults
    command: /opt/app/bin/migrate --reset
    tags:
      - never
      - reset_db
```

```bash
# Normal run - reset_db is SKIPPED
ansible-playbook site.yml

# Explicitly run the dangerous task
ansible-playbook site.yml --tags "reset_db"
```

---

## never - Protect Dangerous Tasks

```yaml
# Destructive operations hidden behind 'never'
- name: Purge old releases
  shell: |
    cd /opt/app/releases
    ls -t | tail -n +4 | xargs rm -rf
  tags:
    - never
    - cleanup

- name: Drop and rebuild database
  command: /opt/db/rebuild.sh
  tags:
    - never
    - rebuild_db
```

> These **never run accidentally** during normal playbook execution

---

## always vs never Summary

| Tag | Default Behavior | Override |
|-----|-----------------|----------|
| `always` | Runs every time | `--skip-tags "always"` |
| `never` | Never runs | `--tags "the_tag_name"` |
| _(no tag)_ | Runs normally | Skipped when `--tags` is used |

---

## Tag Inheritance: Play-Level

All tasks in the play inherit the play-level tag.

```yaml
- name: Web server setup
  hosts: webservers
  tags: websetup          # applied to ALL tasks below

  tasks:
    - name: Install nginx       # inherits 'websetup'
      apt: name=nginx state=present

    - name: Start nginx          # inherits 'websetup'
      service: name=nginx state=started
```

```bash
ansible-playbook site.yml --tags "websetup"
# Runs both tasks
```

---

## Tag Inheritance: Block-Level

All tasks inside a block inherit the block's tag.

```yaml
tasks:
  - name: Security hardening
    tags: security
    block:
      - name: Disable root SSH
        lineinfile:
          path: /etc/ssh/sshd_config
          regexp: "^PermitRootLogin"
          line: "PermitRootLogin no"

      - name: Set SSH idle timeout
        lineinfile:
          path: /etc/ssh/sshd_config
          regexp: "^ClientAliveInterval"
          line: "ClientAliveInterval 300"
```

---

## Practical Pattern: Phased Deployment

Tag tasks by phase for day-to-day operations:

```yaml
tags: install     # Package installation
tags: setup       # Users, directories
tags: config      # Configuration files
tags: firewall    # Network rules
tags: deploy      # Application code
tags: service     # Service management
```

---

## Phased Deployment in Action

```bash
# Day 1: Full server setup (all phases)
ansible-playbook site.yml

# Day 2: Push config change only
ansible-playbook site.yml --tags "config"

# Day 3: Deploy new code + restart services
ansible-playbook site.yml --tags "deploy,service"

# Day 4: Full run but skip slow firewall setup
ansible-playbook site.yml --skip-tags "firewall"
```

> Same playbook, different operations via tags

---

## Practical Example: Full Stack Deployment

```yaml
tasks:
  - name: Install packages
    apt: name={{ item }} state=present
    loop: [nginx, nodejs, ufw]
    tags: install

  - name: Configure nginx reverse proxy
    template: src=nginx.conf.j2 dest=/etc/nginx/sites-available/app
    notify: Reload nginx
    tags: config

  - name: Deploy application code
    synchronize: src=/tmp/build/ dest=/opt/app/current/
    notify: Restart application
    tags: deploy
```

---

## Practical Example (continued)

```yaml
  - name: Configure firewall
    tags: firewall
    block:
      - name: Allow SSH
        ufw: rule=allow port=22 proto=tcp
      - name: Allow HTTP
        ufw: rule=allow port=80 proto=tcp
      - name: Enable firewall
        ufw: state=enabled policy=deny

  - name: Verify app responds
    uri: url=http://localhost:8080/health status_code=200
    tags: always
```

---

## Common Mistakes

### Mistake 1: Forgetting untagged tasks are skipped

```bash
ansible-playbook site.yml --tags "deploy"
# Tasks without ANY tag will NOT run!
```

### Mistake 2: Using --tags when you mean --skip-tags

```bash
# WRONG: "run everything except firewall"
ansible-playbook site.yml --tags "install,config,deploy"

# RIGHT:
ansible-playbook site.yml --skip-tags "firewall"
```

---

## Best Practices

| Practice | Why |
|----------|-----|
| Use consistent tag names | `install`, `config`, `deploy`, `service` |
| Tag by phase, not by task | Easier to remember and combine |
| Use `always` for health checks | Ensures verification after any run |
| Use `never` for destructive ops | Prevents accidental data loss |
| Prefer `--skip-tags` for exclusion | Simpler than listing all other tags |

---

## Quick Reference

```yaml
# Single tag
tags: install

# Multiple tags
tags:
  - install
  - monitoring

# Special tags
tags: always              # runs every time
tags:
  - never                 # skipped by default
  - reset_db              # explicit name to call it

# Play-level tag
- hosts: all
  tags: setup
  tasks: ...

# Block-level tag
- block:
    - name: Task A
    - name: Task B
  tags: security
```

---

## Hands-on Exercises

```bash
cd chapter-07-tags

# List tags available in a playbook
ansible-playbook 01-tag-basics.yml --list-tags

# Run only install tasks
ansible-playbook 01-tag-basics.yml --tags "install"

# Run the 'never' tagged cleanup task
ansible-playbook 02-always-never-tags.yml --tags "cleanup"

# Run block-level tagged tasks
ansible-playbook 03-tag-inheritance.yml --tags "security"

# Phased deployment
ansible-playbook 04-tags-practical.yml --tags "config"
```

---

## Key Takeaways

| Concept | Description |
|---------|-------------|
| `tags` | Label tasks for selective execution |
| `--tags` | Run only matching tasks |
| `--skip-tags` | Exclude matching tasks |
| `always` | Runs regardless of tag filter |
| `never` | Skipped unless explicitly included |
| **Inheritance** | Tags cascade from plays/blocks to tasks |
| **Untagged** | Skipped when `--tags` filter is active |

---

## Next Chapter

# Chapter 08
## Roles

- Organizing playbooks into reusable roles
- Role directory structure
- `defaults`, `tasks`, `handlers`, `templates`
- Galaxy and community roles

---

# Thank You!

### Questions?

**Key Takeaway:**
> "Tags let you run the right tasks at the right time!"

**Resources:**
- [Ansible Tags Docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_tags.html)

---
