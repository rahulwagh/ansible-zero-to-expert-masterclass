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
---

# Chapter 04
# Conditionals

### Control When and How Tasks Run in Ansible

---

## What You'll Learn

- Basic `when` conditionals with variables and facts
- Multiple conditions (AND / OR)
- Using `when` with registered variables
- `failed_when` and `changed_when`
- Conditionals in loops and blocks

---

## The `when` Statement

### Skip or run tasks based on conditions

```yaml
- name: Only run on production
  debug:
    msg: "This is production!"
  when: deploy_env == "production"
```

> Condition is evaluated as **Jinja2 expression** - no `{{ }}` needed!

---

## How `when` Works

```
┌─────────────────────────────────────────────────────────┐
│                    TASK EXECUTION                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   when: condition                                        │
│         │                                                │
│         ├── true  ───► Task RUNS                        │
│         │                                                │
│         └── false ───► Task SKIPPED                     │
│                                                          │
│   No curly braces {{ }} needed in when clause!          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Boolean Checks

```yaml
vars:
  debug_mode: false

tasks:
  - name: Task runs when debug is OFF
    debug:
      msg: "Debug mode is OFF"
    when: not debug_mode

  - name: Task runs when debug is ON
    debug:
      msg: "Debugging enabled!"
    when: debug_mode
```

---

## String Comparison

```yaml
vars:
  deploy_env: "production"

tasks:
  - name: Production environment
    debug:
      msg: "Running in production"
    when: deploy_env == "production"

  - name: Not development
    debug:
      msg: "Not in dev mode"
    when: deploy_env != "development"
```

---

## The `in` Operator

### Check if value exists in a list

```yaml
vars:
  deploy_env: "staging"
  allowed_envs:
    - production
    - staging
    - development

tasks:
  - name: Validate environment
    debug:
      msg: "{{ deploy_env }} is valid"
    when: deploy_env in allowed_envs
```

---

## Using Ansible Facts

```yaml
- name: Debian-based system
  debug:
    msg: "Use apt package manager"
  when: ansible_os_family == "Debian"

- name: RedHat-based system
  debug:
    msg: "Use yum/dnf package manager"
  when: ansible_os_family == "RedHat"

- name: Check memory (numeric comparison)
  debug:
    msg: "System has sufficient memory"
  when: ansible_memtotal_mb >= 1024
```

---

## Common Facts for Conditionals

| Fact | Example Value |
|------|---------------|
| `ansible_os_family` | Debian, RedHat |
| `ansible_distribution` | Ubuntu, CentOS |
| `ansible_distribution_version` | 22.04, 8 |
| `ansible_memtotal_mb` | 4096 |
| `ansible_processor_vcpus` | 4 |
| `ansible_architecture` | x86_64 |

---

## Group Membership

```yaml
- name: Webserver tasks
  debug:
    msg: "{{ inventory_hostname }} is a webserver"
  when: "'webservers' in group_names"

- name: Database tasks
  debug:
    msg: "{{ inventory_hostname }} is a database server"
  when: "'dbservers' in group_names"
```

> `group_names` = list of groups the current host belongs to

---

## Variable Existence

```yaml
- name: Check if variable exists
  debug:
    msg: "deploy_env is set to {{ deploy_env }}"
  when: deploy_env is defined

- name: Handle undefined variable
  debug:
    msg: "Using default value"
  when: optional_var is not defined
```

> Prevents errors from undefined variables!

---

## Comparison Operators

| Operator | Example | Description |
|----------|---------|-------------|
| `==` | `when: env == "prod"` | Equal |
| `!=` | `when: env != "dev"` | Not equal |
| `>` | `when: count > 5` | Greater than |
| `<` | `when: count < 10` | Less than |
| `>=` | `when: mem >= 1024` | Greater or equal |
| `<=` | `when: disk <= 80` | Less or equal |

---

## Multiple Conditions: AND

### Use YAML list format - ALL conditions must be true

```yaml
- name: Production webserver with enough memory
  debug:
    msg: "Production webserver ready!"
  when:
    - environment == "production"
    - "'webservers' in group_names"
    - ansible_memtotal_mb >= 512
```

> All three conditions must be `true` for task to run

---

## AND Conditions Visual

```
┌─────────────────────────────────────────────────────────┐
│                   AND CONDITIONS                         │
│                   (YAML List Format)                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   when:                                                  │
│     - condition1    ──┐                                  │
│     - condition2    ──┼──► ALL must be TRUE             │
│     - condition3    ──┘                                  │
│                                                          │
│   condition1: true  ┐                                    │
│   condition2: true  ├──► Task RUNS                      │
│   condition3: true  ┘                                    │
│                                                          │
│   condition1: true  ┐                                    │
│   condition2: false ├──► Task SKIPPED                   │
│   condition3: true  ┘                                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Multiple Conditions: OR

### Use `or` keyword - ANY condition can be true

```yaml
- name: Web or database server
  debug:
    msg: "This host handles traffic"
  when: "'webservers' in group_names or 'dbservers' in group_names"
```

Alternative with `in`:
```yaml
- name: Valid environment
  debug:
    msg: "Environment is valid"
  when: environment in ['production', 'staging', 'development']
```

---

## OR Conditions Visual

```
┌─────────────────────────────────────────────────────────┐
│                    OR CONDITIONS                         │
│                   (or keyword)                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   when: condition1 or condition2 or condition3          │
│                                                          │
│   ANY one being TRUE = Task RUNS                        │
│                                                          │
│   condition1: false ┐                                    │
│   condition2: true  ├──► Task RUNS                      │
│   condition3: false ┘                                    │
│                                                          │
│   condition1: false ┐                                    │
│   condition2: false ├──► Task SKIPPED                   │
│   condition3: false ┘                                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Complex Conditions

### Combine AND and OR with parentheses

```yaml
- name: Ubuntu with 1GB+ RAM, OR any CentOS
  debug:
    msg: "Supported configuration"
  when: >
    (ansible_distribution == "Ubuntu" and ansible_memtotal_mb >= 1024)
    or ansible_distribution == "CentOS"
```

> Use `>` for multi-line conditions

---

## Version Comparison

```yaml
vars:
  app_version: "2.5.0"

tasks:
  - name: Version between 2.0 and 3.0
    debug:
      msg: "App version {{ app_version }} is supported"
    when:
      - app_version is version('2.0.0', '>=')
      - app_version is version('3.0.0', '<')
```

> Operators: `==`, `!=`, `<`, `>`, `<=`, `>=`

---

## Register Variables

### Capture task output for later decisions

```yaml
- name: Check if file exists
  stat:
    path: /etc/nginx/nginx.conf
  register: nginx_conf

- name: File exists
  debug:
    msg: "Nginx config found!"
  when: nginx_conf.stat.exists
```

---

## Register Flow

```
┌─────────────────────────────────────────────────────────┐
│                  REGISTER WORKFLOW                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Task 1: stat module                                    │
│   ┌─────────────────────┐                                │
│   │ Check /etc/hosts    │ ──► register: file_result     │
│   └─────────────────────┘                                │
│                             │                            │
│                             ▼                            │
│   file_result:                                           │
│   ┌─────────────────────────────────────┐               │
│   │ stat:                               │               │
│   │   exists: true                      │               │
│   │   size: 1234                        │               │
│   │   isdir: false                      │               │
│   └─────────────────────────────────────┘               │
│                             │                            │
│                             ▼                            │
│   Task 2: when: file_result.stat.exists                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Register: Command Return Codes

```yaml
- name: Check if nginx is installed
  command: which nginx
  register: nginx_check
  ignore_errors: true
  changed_when: false

- name: Nginx found
  debug:
    msg: "Nginx at {{ nginx_check.stdout }}"
  when: nginx_check.rc == 0

- name: Nginx not found - install it
  debug:
    msg: "Would install nginx here"
  when: nginx_check.rc != 0
```

---

## Register: Parse Output

```yaml
- name: Get disk usage
  shell: df / | tail -1 | awk '{print $5}' | tr -d '%'
  register: disk_usage
  changed_when: false

- name: Disk OK
  debug:
    msg: "Disk usage: {{ disk_usage.stdout }}%"
  when: disk_usage.stdout | int <= 80

- name: Disk Warning!
  debug:
    msg: "WARNING: Disk at {{ disk_usage.stdout }}%!"
  when: disk_usage.stdout | int > 80
```

---

## Register: Changed Status

```yaml
- name: Create config file
  template:
    src: app.conf.j2
    dest: /etc/app/app.conf
  register: config_result

- name: Restart service if config changed
  service:
    name: myapp
    state: restarted
  when: config_result.changed
```

> Only restart when configuration actually changes!

---

## `failed_when`

### Customize when a task is considered **failed**

```yaml
# Default: rc != 0 = failure
# Custom: only fail if rc >= 2
- name: Allow rc=1
  shell: exit 1
  register: result
  failed_when: result.rc >= 2

# Fail based on output content
- name: Check for errors
  shell: /opt/app/healthcheck.sh
  register: health
  failed_when: "'ERROR' in health.stdout"
```

---

## `failed_when` Visual

```
┌─────────────────────────────────────────────────────────┐
│                    failed_when                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   DEFAULT BEHAVIOR:                                      │
│   ┌─────────────────────────────────────┐               │
│   │ command returns rc != 0 ──► FAILED  │               │
│   └─────────────────────────────────────┘               │
│                                                          │
│   WITH failed_when:                                      │
│   ┌─────────────────────────────────────┐               │
│   │ failed_when: result.rc >= 2         │               │
│   │                                     │               │
│   │ rc = 0 ──► OK                       │               │
│   │ rc = 1 ──► OK (customized!)         │               │
│   │ rc = 2 ──► FAILED                   │               │
│   └─────────────────────────────────────┘               │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## `failed_when: false`

### Never fail - useful for optional checks

```yaml
- name: Try to connect (might fail)
  command: /opt/check_connection.sh
  register: connection
  failed_when: false

- name: Connection status
  debug:
    msg: "Connection {{ 'OK' if connection.rc == 0 else 'FAILED' }}"
```

> Task always succeeds, but you can still check the result

---

## `changed_when`

### Control when a task reports **"changed"**

```yaml
# Read-only command - never reports changed
- name: Get current user
  command: whoami
  register: user
  changed_when: false

# Change based on output
- name: Create resource
  shell: /opt/create_resource.sh
  register: result
  changed_when: "'CREATED' in result.stdout"
```

---

## `changed_when` for Idempotency

```yaml
- name: Create marker if missing
  shell: |
    if [ -f /tmp/marker ]; then
      echo "EXISTS"
    else
      touch /tmp/marker
      echo "CREATED"
    fi
  register: marker
  changed_when: "'CREATED' in marker.stdout"
```

> First run: `changed=true` | Second run: `changed=false`

---

## changed_when Visual

```
┌─────────────────────────────────────────────────────────┐
│                   changed_when                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   DEFAULT: command/shell always report "changed"        │
│                                                          │
│   changed_when: false                                    │
│   └── Never reports changed (read-only commands)        │
│                                                          │
│   changed_when: "'CREATED' in result.stdout"            │
│   └── First run:  stdout="CREATED" ──► changed=true     │
│   └── Second run: stdout="EXISTS"  ──► changed=false    │
│                                                          │
│   IDEMPOTENCY achieved!                                  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Conditionals in Loops

### Filter items with `when`

```yaml
vars:
  packages:
    - { name: nginx, install: true }
    - { name: mysql, install: false }
    - { name: redis, install: true }

tasks:
  - name: Install enabled packages only
    apt:
      name: "{{ item.name }}"
      state: present
    loop: "{{ packages }}"
    when: item.install
```

---

## Loop + Register + Condition

```yaml
- name: Check multiple files
  stat:
    path: "{{ item }}"
  loop:
    - /etc/hosts
    - /etc/passwd
    - /nonexistent
  register: file_checks

- name: Show existing files
  debug:
    msg: "{{ item.item }} exists"
  loop: "{{ file_checks.results }}"
  when: item.stat.exists
```

---

## Blocks with Conditions

### Apply **one condition** to multiple tasks

```yaml
- name: Webserver configuration
  when: "'webservers' in group_names"
  block:
    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf

    - name: Setup SSL certificates
      copy:
        src: ssl/
        dest: /etc/nginx/ssl/

    - name: Start nginx
      service:
        name: nginx
        state: started
```

---

## Block Visual

```
┌─────────────────────────────────────────────────────────┐
│                    BLOCKS                                │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   when: "'webservers' in group_names"                   │
│   block:                                                 │
│     ┌─────────────────────────────────────────────┐     │
│     │ - Configure nginx       ◄── Condition       │     │
│     │ - Setup SSL               applies to        │     │
│     │ - Open firewall           ALL tasks         │     │
│     │ - Start nginx             in block          │     │
│     └─────────────────────────────────────────────┘     │
│                                                          │
│   Instead of writing `when:` on each task!              │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## OS-Specific Blocks

```yaml
- name: Debian tasks
  when: ansible_os_family == "Debian"
  block:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install packages
      apt:
        name: [nginx, php, mysql-client]
        state: present

- name: RedHat tasks
  when: ansible_os_family == "RedHat"
  block:
    - name: Install packages
      yum:
        name: [nginx, php, mysql]
        state: present
```

---

## Quick Reference: Jinja2 Tests

| Test | Example |
|------|---------|
| `is defined` | `when: var is defined` |
| `is not defined` | `when: var is not defined` |
| `is none` | `when: var is none` |
| `is true` | `when: flag is true` |
| `is false` | `when: flag is false` |
| `is version()` | `when: ver is version('2.0', '>=')` |

---

## Quick Reference: Patterns

```yaml
# AND - all must be true (YAML list)
when:
  - condition1
  - condition2

# OR - any can be true
when: condition1 or condition2

# Complex (parentheses)
when: (A and B) or C

# Negation
when: not condition

# Check undefined with default
when: (my_var | default('')) != ''
```

---

## Decision Tree

```
┌─────────────────────────────────────────────────────────┐
│            WHICH CONDITIONAL TO USE?                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Skip a single task? ──────────────────► when:         │
│                                                          │
│   Skip multiple related tasks? ─────────► block: + when:│
│                                                          │
│   React to previous task result? ───────► register +    │
│                                            when:         │
│                                                          │
│   Customize failure detection? ─────────► failed_when:  │
│                                                          │
│   Control "changed" reporting? ─────────► changed_when: │
│                                                          │
│   Filter loop items? ───────────────────► loop + when:  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Key Takeaways

| Concept | Purpose |
|---------|---------|
| `when` | Skip tasks based on conditions |
| AND (list) | All conditions must be true |
| OR | Any condition can be true |
| `register` | Capture task results for decisions |
| `failed_when` | Custom failure conditions |
| `changed_when` | Control change reporting |
| `block` | Apply one condition to many tasks |

---

## Hands-on Exercises

```bash
cd chapter-04-conditionals

# Run the playbooks
ansible-playbook 01-when-basics.yml
ansible-playbook 02-multiple-conditions.yml
ansible-playbook 03-when-with-register.yml
ansible-playbook 04-failed-changed-when.yml
ansible-playbook 05-conditionals-loops-blocks.yml

# Try with different variables
ansible-playbook 01-when-basics.yml -e "deploy_env=staging"
```

---

## Summary

### What We Learned:

- Basic `when` with variables, facts, and comparisons
- AND conditions (YAML list format)
- OR conditions (`or` keyword)
- Complex conditions with parentheses
- `register` for capturing task output
- `failed_when` for custom failure handling
- `changed_when` for idempotency
- Conditionals in loops and blocks

---

## Next Chapter

# Chapter 05
## Loops

- Iterating over lists and dictionaries
- Loop controls (index, first, last)
- Nested loops
- Until loops (retries)

---

# Thank You!

### Questions?

**Key Takeaway:**
> "Use `when` to make tasks smart and conditional!"

**Resources:**
- [Ansible Conditionals Docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)
- [Jinja2 Tests](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_tests.html)

---
