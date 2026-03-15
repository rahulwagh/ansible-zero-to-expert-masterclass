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

# Chapter 08
# Templates with Jinja2

### Generate Dynamic Config Files with Ansible

---

## What You'll Learn

- Using the `template` module to deploy config files
- Jinja2 variable interpolation with `{{ }}`
- Jinja2 control structures: `{% if %}`, `{% for %}`
- Built-in and Ansible-specific filters
- Template validation with the `validate` option
- The `template` lookup for in-memory rendering

---

## What Is the template Module?

**template** renders a Jinja2 `.j2` file on the **control node** and uploads the result to the **managed host**.

```yaml
tasks:
  - name: Deploy nginx config
    template:
      src: templates/nginx.conf.j2   # local .j2 file
      dest: /etc/nginx/nginx.conf    # destination on host
      mode: '0644'
```

> All playbook **variables** and **facts** are automatically available inside the template

---

## template vs copy

| Feature | `copy` | `template` |
|---------|--------|------------|
| Variable interpolation | ❌ | ✅ |
| Conditionals (`if/else`) | ❌ | ✅ |
| Loops (`for`) | ❌ | ✅ |
| Static file transfer | ✅ | ✅ |
| validate option | ❌ | ✅ |

> Use **template** whenever a file needs variables. Use **copy** for truly static files.

---

## Jinja2 Syntax Basics

```jinja2
{# This is a comment — not rendered in the output #}

{{ variable }}                  {# Variable interpolation  #}
{{ var | filter }}              {# Filter pipeline         #}
{{ var | filter1 | filter2 }}   {# Chained filters         #}

{% if condition %}              {# Conditional block start #}
  ...
{% elif other %}
  ...
{% else %}
  ...
{% endif %}

{% for item in list %}          {# Loop block              #}
  {{ item }}
{% endfor %}
```

---

## Variable Interpolation

Any variable in scope is available directly inside the `.j2` file.

```jinja2
# nginx.conf.j2

worker_processes {{ nginx_worker_processes | default('auto') }};

server {
    listen {{ app_port }};
    server_name {{ app_name }}.example.com;
    root {{ web_root | default('/var/www/html') }};
}
```

```yaml
# playbook.yml
vars:
  app_name: myapp
  app_port: 8080
  nginx_worker_processes: 4
```

---

## Conditionals in Templates

```jinja2
# app.conf.j2

[logging]
level = {{ log_level | default('INFO') }}

{% if server_env == 'production' %}
max_connections = 500
debug = false
{% elif server_env == 'staging' %}
max_connections = 50
debug = true
{% else %}
max_connections = 10
debug = true
{% endif %}
```

> Same template, different output per environment

---

## Conditionals in Templates — Result

```bash
# Production output:
[logging]
level = WARNING
max_connections = 500
debug = false

# Staging output:
[logging]
level = WARNING
max_connections = 50
debug = true
```

> One template file, multiple environments

---

## Loops in Templates

```jinja2
# nginx.conf.j2

http {
{% for vhost in nginx_vhosts %}
    server {
        listen {{ vhost.port | default(80) }};
        server_name {{ vhost.server_name }};
        root {{ vhost.root }};
{% if vhost.proxy_pass is defined %}
        location /api {
            proxy_pass {{ vhost.proxy_pass }};
        }
{% endif %}
    }
{% endfor %}
}
```

---

## Loops in Templates — Playbook

```yaml
vars:
  nginx_vhosts:
    - server_name: "example.com"
      port: 80
      root: "/var/www/example"
    - server_name: "api.example.com"
      port: 80
      root: "/var/www/api"
      proxy_pass: "http://127.0.0.1:3000"
```

> The loop in the template iterates over the list at render time

---

## Filters — What Are They?

**Filters** transform variable values inline using the `|` pipe syntax.

```jinja2
{{ "hello world" | upper }}           {# HELLO WORLD   #}
{{ "  trim me  " | trim }}            {# trim me       #}
{{ 53687091200   | filesizeformat }}  {# 50.0 GB       #}
{{ maybe_null    | default('N/A') }}  {# N/A           #}
```

Filters can be **chained**:

```jinja2
{{ "  my app  " | trim | title }}     {# My App        #}
{{ raw_csv | split(',') | map('trim') | list }}
```

---

## Filters — String

| Filter | Example | Result |
|--------|---------|--------|
| `upper` | `"hello" \| upper` | `HELLO` |
| `lower` | `"HELLO" \| lower` | `hello` |
| `trim` | `"  hi  " \| trim` | `hi` |
| `title` | `"hello world" \| title` | `Hello World` |
| `replace` | `"foo" \| replace("o","0")` | `f00` |
| `truncate(8)` | `"long text" \| truncate(8)` | `long ...` |
| `basename` | `"/etc/nginx.conf" \| basename` | `nginx.conf` |
| `dirname` | `"/etc/nginx.conf" \| dirname` | `/etc` |

---

## Filters — Numeric & Size

| Filter | Example | Result |
|--------|---------|--------|
| `int` | `"42" \| int` | `42` |
| `float` | `"3.14" \| float` | `3.14` |
| `round(2)` | `0.6666 \| round(2)` | `0.67` |
| `abs` | `-5 \| abs` | `5` |
| `filesizeformat` | `1073741824 \| filesizeformat` | `1.0 GB` |
| `pow(2)` | `10 \| pow(2)` | `100` |

```jinja2
# MOTD example
Memory : {{ (ansible_memtotal_mb / 1024) | round(1) }} GB
Disk   : {{ ansible_mounts[0].size_total | filesizeformat }}
```

---

## Filters — Lists

| Filter | Result |
|--------|--------|
| `length` | Count of items |
| `first` / `last` | First or last element |
| `sort` | Sorted list |
| `reverse \| list` | Reversed list |
| `join(', ')` | Comma-separated string |
| `unique \| list` | Deduplicated list |
| `min` / `max` | Smallest or largest value |
| `sum` | Sum of all values |

```jinja2
{% for pkg in packages | sort %}
  - {{ pkg }}
{% endfor %}
```

---

## Filters — Default & Boolean

```jinja2
{# Provide a fallback when variable is undefined or null #}
{{ timeout      | default(30) }}
{{ app_version  | default('1.0.0') }}

{# omit skips the parameter entirely in tasks #}
{{ optional_arg | default(omit) }}

{# Boolean conversion #}
{{ 'yes'  | bool }}      {# True  #}
{{ 'no'   | bool }}      {# False #}

{# Ternary — inline if/else #}
{{ (env == 'production') | ternary('PROD', 'NON-PROD') }}
{{ nginx_gzip | ternary('on', 'off') }}
```

---

## Filters — Hash & Encoding

```jinja2
{# Hashing #}
{{ 'mypassword' | hash('sha256') }}
{{ 'mypassword' | password_hash('sha512') }}

{# Base64 #}
{{ 'hello ansible' | b64encode }}    {# aGVsbG8gYW5zaWJsZQ== #}
{{ 'aGVsbG8=' | b64decode }}         {# hello                 #}

{# Serialization #}
{{ server_tags | to_json }}
{{ server_tags | to_nice_yaml }}
{{ '{"key":"val"}' | from_json }}
```

---

## template Module — Key Options

| Option | Required | Description |
|--------|----------|-------------|
| `src` | ✅ | Path to `.j2` file (relative to playbook) |
| `dest` | ✅ | Destination path on managed host |
| `mode` | No | File permissions, e.g. `'0644'` |
| `owner` / `group` | No | File ownership |
| `backup` | No | Keep timestamped backup of previous file |
| `validate` | No | Shell command to validate before writing |
| `diff` | No | Show diff of changes per task |

---

## validate Option

**validate** runs a check command on a temp copy **before** writing the real file.

```yaml
- name: Deploy nginx config
  template:
    src: templates/nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    mode: '0644'
    validate: '/usr/sbin/nginx -t -c %s'
```

```
                     ┌─────────────────────────────┐
  Render .j2  ──►    │  Write to temp file (%s)     │
                     │  Run validate command         │
                     │  ✅ Pass → copy to dest       │
                     │  ❌ Fail → abort, no change   │
                     └─────────────────────────────┘
```

> Original file is **never touched** if validation fails

---

## backup Option

```yaml
- name: Deploy application config
  template:
    src: templates/app.conf.j2
    dest: /etc/myapp/app.conf
    backup: true
```

```bash
# Before:
/etc/myapp/app.conf

# After (when file changes):
/etc/myapp/app.conf                        # new version
/etc/myapp/app.conf.2024-03-15@14:32~      # timestamped backup
```

> Always use `backup: true` for production configuration files

---

## template + notify Handler

```yaml
tasks:
  - name: Deploy nginx config
    template:
      src: templates/nginx.conf.j2
      dest: /etc/nginx/nginx.conf
      validate: '/usr/sbin/nginx -t -c %s'
      backup: true
    notify: Reload nginx          # only triggers on change

  - name: Ensure nginx is running
    service:
      name: nginx
      state: started
      enabled: true

handlers:
  - name: Reload nginx
    service:
      name: nginx
      state: reloaded
```

---

## template Lookup

Render a template **on the control node** without writing to a host.

```yaml
- name: Preview rendered MOTD
  debug:
    msg: "{{ lookup('template', 'templates/motd.j2') }}"
```

```yaml
# Pass rendered content to another module
- name: Create secret from template
  community.kubernetes.k8s:
    definition: "{{ lookup('template', 'templates/secret.j2') | from_yaml }}"
```

> Useful for **debugging** templates or **piping** rendered content into other modules

---

## template + loop

Deploy a config file per application from a list:

```yaml
vars:
  app_configs:
    - { name: api-server, port: 8080, env: production }
    - { name: worker,     port: 0,    env: production }

tasks:
  - name: Deploy config per app
    template:
      src: templates/app.conf.j2
      dest: "/etc/apps/{{ item.name }}.conf"
      mode: '0640'
    loop: "{{ app_configs }}"
    loop_control:
      label: "{{ item.name }}"
    vars:
      app_name: "{{ item.name }}"
      app_port: "{{ item.port }}"
      app_env:  "{{ item.env }}"
```

---

## Dry-Run Workflow

```bash
# Preview every template change before applying it
ansible-playbook site.yml --check --diff
```

```
TASK [Deploy nginx config] ************************************
--- before: /etc/nginx/nginx.conf
+++ after: /tmp/ansible-tmp.j2
@@ -1,5 +1,5 @@
 worker_processes 2;
-keepalive_timeout 65;
+keepalive_timeout 75;
```

| Flag | Effect |
|------|--------|
| `--check` | No-op — no changes applied |
| `--diff` | Shows unified diff for every file |

> Always run `--check --diff` before pushing config changes to production

---

## set_fact + Filter Pipeline

Use `set_fact` to pre-process variables before passing them into templates:

```yaml
vars:
  raw_packages: "nginx,curl, git ,  vim"

tasks:
  - name: Normalise package list
    set_fact:
      clean_packages: >-
        {{ raw_packages.split(',') | map('trim') | list }}

  - name: Install packages
    apt:
      name: "{{ clean_packages }}"
      state: present
```

> `split` → `map('trim')` → `list` cleans up messy input

---

## MOTD Template — Real Example

```jinja2
# motd.j2
##############################################################
  Hostname : {{ ansible_hostname }}
  OS       : {{ ansible_distribution }} {{ ansible_distribution_version }}
  CPU      : {{ ansible_processor_vcpus }} vCPU(s)
  Memory   : {{ (ansible_memtotal_mb / 1024) | round(1) }} GB
  IP       : {{ ansible_default_ipv4.address }}
  Env      : {{ server_env | default('production') | upper }}

{% if server_env | default('production') == 'production' %}
  *** PRODUCTION SERVER — PROCEED WITH CAUTION ***
{% else %}
  *** {{ server_env | upper }} ENVIRONMENT ***
{% endif %}
##############################################################
```

---

## Common Mistakes

### Mistake 1: Forgetting `gather_facts`

```yaml
- hosts: all
  gather_facts: false   # ❌ ansible_hostname, ansible_os_family etc. unavailable

  tasks:
    - template:
        src: motd.j2    # Will fail — facts not collected
```

### Mistake 2: Undefined variable with no default

```jinja2
{# ❌ Fails if app_port is not defined #}
listen {{ app_port }};

{# ✅ Safe fallback #}
listen {{ app_port | default(80) }};
```

---

## Common Mistakes (continued)

### Mistake 3: Missing validate — bad config reaches the host

```yaml
# ❌ No validate — broken nginx config goes live
- template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf

# ✅ Validate first
- template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    validate: '/usr/sbin/nginx -t -c %s'
```

### Mistake 4: `.j2` extension in dest

```yaml
dest: /etc/nginx/nginx.conf.j2   # ❌ extension stays on host
dest: /etc/nginx/nginx.conf      # ✅ correct
```

---

## Best Practices

| Practice | Why |
|----------|-----|
| Always use `validate` for service configs | Prevents broken configs from going live |
| Always use `backup: true` in production | Instant rollback if something goes wrong |
| Use `default()` for optional variables | Prevents task failure on undefined vars |
| Run `--check --diff` before prod push | Shows exactly what will change |
| Keep template logic minimal | Complex logic belongs in playbook vars |
| Use `gather_facts: true` | Provides system facts to templates |

---

## template vs copy vs lineinfile

```
┌────────────────┬───────────────────────────────────────────┐
│ Module         │ Use When                                  │
├────────────────┼───────────────────────────────────────────┤
│ template       │ Config needs variables, loops, or logic   │
│ copy           │ File is static (no variable substitution) │
│ lineinfile     │ Change or add a single line in a file     │
│ blockinfile    │ Insert/replace a block of lines           │
└────────────────┴───────────────────────────────────────────┘
```

> **Rule of thumb:** if the file ever needs a hostname, IP, port, or environment name — use `template`

---

## Hands-on Exercises

```bash
cd chapter-08-templates

# Run template basics (MOTD + nginx config + app config)
ansible-playbook 01-template-basics.yml

# Explore every filter category
ansible-playbook 02-jinja2-filters.yml

# Full stack deployment dry-run
ansible-playbook 03-templates-practical.yml --check --diff

# Full stack deployment
ansible-playbook 03-templates-practical.yml
```

---

## Quick Reference

```jinja2
{# Variable         #}  {{ variable }}
{# Filter           #}  {{ var | upper | trim }}
{# Default          #}  {{ var | default('fallback') }}
{# Ternary          #}  {{ (x > 0) | ternary('pos', 'neg') }}
{# Conditional      #}  {% if env == 'prod' %} ... {% endif %}
{# Loop             #}  {% for item in list %} ... {% endfor %}
{# Comment          #}  {# not rendered #}
{# Size format      #}  {{ bytes | filesizeformat }}
{# JSON             #}  {{ dict | to_json }}
{# b64              #}  {{ string | b64encode }}
```

---

## Key Takeaways

| Concept | Description |
|---------|-------------|
| `template` | Renders Jinja2 `.j2` on control node, uploads result |
| `{{ }}` | Variable interpolation — all vars and facts available |
| `{% %}` | Control structures: `if`, `for`, `set` |
| Filters `\|` | Transform data inline — chainable |
| `default` | Safe fallback for optional variables |
| `validate` | Prevents bad configs landing on the host |
| `backup` | Timestamped copy of previous file |
| `--check --diff` | Dry-run — shows what would change |

---

## Next Chapter

# Chapter 09
## Register & Debug

- Capturing task output with `register`
- Inspecting results with `debug`
- Asserting expected state with `assert`
- Failing explicitly with `fail`

---

# Thank You!

### Questions?

**Key Takeaway:**
> "Use templates whenever a file needs a variable — one `.j2` file serves every environment!"

**Resources:**
- [Ansible template module docs](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)
- [Jinja2 template designer docs](https://jinja.palletsprojects.com/en/3.1.x/templates/)

---
