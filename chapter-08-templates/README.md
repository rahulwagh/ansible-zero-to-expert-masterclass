# Chapter 08 - Templates with Jinja2

Generate dynamic configuration files using the `template` module and Jinja2 expressions.

## What You'll Learn

- Using the `template` module to deploy config files
- Jinja2 variable interpolation (`{{ }}`) inside `.j2` files
- Jinja2 control structures: `{% if %}`, `{% for %}`
- Built-in Jinja2 filters + Ansible-specific filters
- Template validation with the `validate` option
- The `template` lookup for in-memory rendering

---

## Quick Start

```bash
cd chapter-08-templates
ansible all -m ping
ansible-playbook 01-template-basics.yml
```

---

## Directory Structure

```
chapter-08-templates/
├── ansible.cfg
├── inventory/
│   └── hosts.ini
├── templates/                    # Jinja2 template files (.j2)
│   ├── nginx.conf.j2             # Nginx main config
│   ├── app.conf.j2               # Generic app config (INI style)
│   ├── motd.j2                   # Message of the day
│   ├── index.html.j2             # HTML landing page
│   └── sudoers_snippet.j2        # Sudoers fragment
├── 01-template-basics.yml        # template module fundamentals
├── 02-jinja2-filters.yml         # Filter reference playbook
├── 03-template-advanced.yml      # Conditionals, loops, lookups
├── 04-templates-practical.yml    # Full stack deployment
└── README.md
```

---

## Playbooks

| # | Playbook | Concepts Covered |
|---|----------|------------------|
| 01 | template-basics.yml | `template` module, `src`/`dest`, `validate`, `backup` |
| 02 | jinja2-filters.yml | String, numeric, list, dict, hash, encoding filters |
| 03 | templates-practical.yml | Full nginx + app deployment, `--check --diff` |

---

## Run the Playbooks

### Playbook 01: Template Basics

```bash
# Deploy MOTD, nginx config, and app config
ansible-playbook 01-template-basics.yml

# Run with verbose output to see rendered values
ansible-playbook 01-template-basics.yml -v
```

**Covers:** `template` module options, `validate`, `backup`, handlers

---

### Playbook 02: Jinja2 Filters

```bash
# Run all filter demos (no changes on host — all debug output)
ansible-playbook 02-jinja2-filters.yml

# Run only string filter examples
ansible-playbook 02-jinja2-filters.yml --tags string_filters
```

**Covers:** Every major filter category with side-by-side examples

---

### Playbook 03: Practical Full Deployment

```bash
# Full deployment
ansible-playbook 03-templates-practical.yml

# Dry-run with diff to see every change
ansible-playbook 03-templates-practical.yml --check --diff

# Deploy packages only
ansible-playbook 03-templates-practical.yml --tags "packages"

# Re-deploy configs + reload nginx without touching packages
ansible-playbook 03-templates-practical.yml --tags "config,service"

# Deploy app code + verify
ansible-playbook 03-templates-practical.yml --tags "deploy,verify"
```

**Covers:** Real-world multi-template deployment, pre/post tasks, verification

---

## Template Syntax Quick Reference

### Variable Interpolation

```jinja2
{{ variable }}
{{ ansible_hostname }}
{{ app_name | upper }}
{{ app_port | default(8080) }}
```

### Conditionals

```jinja2
{% if server_env == 'production' %}
  worker_processes auto;
{% else %}
  worker_processes 1;
{% endif %}
```

### Loops

```jinja2
{% for vhost in nginx_vhosts %}
server {
    listen {{ vhost.port | default(80) }};
    server_name {{ vhost.server_name }};
}
{% endfor %}
```

### Comments

```jinja2
{# This line will not appear in the rendered file #}
```

---

## Filter Cheat Sheet

### String Filters

| Filter | Example | Result |
|--------|---------|--------|
| `upper` | `"hello" \| upper` | `HELLO` |
| `lower` | `"HELLO" \| lower` | `hello` |
| `trim` | `"  hi  " \| trim` | `hi` |
| `title` | `"hello world" \| title` | `Hello World` |
| `replace` | `"foo" \| replace("o","0")` | `f00` |
| `basename` | `"/etc/nginx.conf" \| basename` | `nginx.conf` |
| `dirname` | `"/etc/nginx.conf" \| dirname` | `/etc` |

### Numeric Filters

| Filter | Example | Result |
|--------|---------|--------|
| `int` | `"42" \| int` | `42` |
| `float` | `"3.14" \| float` | `3.14` |
| `round(2)` | `0.666 \| round(2)` | `0.67` |
| `abs` | `-5 \| abs` | `5` |
| `filesizeformat` | `1073741824 \| filesizeformat` | `1.0 GB` |

### List Filters

| Filter | Example | Result |
|--------|---------|--------|
| `length` | `list \| length` | count |
| `first` | `list \| first` | first item |
| `last` | `list \| last` | last item |
| `sort` | `list \| sort` | sorted list |
| `join(', ')` | `list \| join(', ')` | comma string |
| `unique` | `list \| unique \| list` | deduped list |
| `min` / `max` | `list \| min` | smallest item |

### Default / Boolean Filters

| Filter | Example | Result |
|--------|---------|--------|
| `default` | `var \| default('fallback')` | value or fallback |
| `bool` | `"yes" \| bool` | `True` |
| `ternary` | `(x==1) \| ternary('a','b')` | `a` or `b` |
| `mandatory` | `var \| mandatory` | fail if undefined |

### Hash / Encoding Filters

| Filter | Example | Result |
|--------|---------|--------|
| `hash('sha256')` | `"pw" \| hash('sha256')` | hex digest |
| `b64encode` | `"hi" \| b64encode` | `aGk=` |
| `b64decode` | `"aGk=" \| b64decode` | `hi` |
| `to_json` | `dict \| to_json` | JSON string |
| `to_nice_yaml` | `dict \| to_nice_yaml` | YAML string |

---

## template Module Options

| Option | Required | Description |
|--------|----------|-------------|
| `src` | ✅ | Path to `.j2` file (relative to playbook dir) |
| `dest` | ✅ | Destination path on managed host |
| `mode` | No | Permissions (e.g. `'0644'`) |
| `owner` | No | File owner |
| `group` | No | File group |
| `backup` | No | Create timestamped backup of existing file |
| `validate` | No | Command to validate file before writing (`%s` = temp path) |
| `diff` | No | Show diff of changes per task |

---

## template vs copy vs lineinfile

```
┌────────────────┬───────────────────────────────────────────────┐
│ Module         │ Use When                                      │
├────────────────┼───────────────────────────────────────────────┤
│ template       │ Config file needs variables / logic           │
│ copy           │ File is static (no variable substitution)     │
│ lineinfile     │ Need to change/add a single line in a file    │
│ blockinfile    │ Need to insert/replace a block of lines       │
└────────────────┴───────────────────────────────────────────────┘
```

---

## Dry-Run Workflow

```bash
# Preview every template change before applying
ansible-playbook 04-templates-practical.yml --check --diff
```

- `--check` — runs in no-op mode (no changes applied)
- `--diff` — shows a unified diff for every file that would change
- Use both together before any production config push

---

## Key Takeaways

1. **`template`** — renders Jinja2 on the control node and uploads the result
2. **`{{ }}`** — variable interpolation; all playbook vars and facts available
3. **`{% %}`** — control structures: `if`, `for`, `set`, `macro`
4. **Filters** — transform data inline with `|`; chain multiple filters
5. **`default`** — safe fallback for optional variables
6. **`validate`** — prevents bad configs from landing on the host
7. **`backup`** — keeps a timestamped copy of the previous file
8. **`--check --diff`** — always dry-run template changes in production
