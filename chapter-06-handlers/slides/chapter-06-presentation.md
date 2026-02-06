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

# Chapter 06
# Handlers

### Trigger Actions Only When Changes Occur

---

## What You'll Learn

- What handlers are and why use them
- Basic handler syntax with `notify`
- Handler execution order
- Multiple handlers and chaining
- `listen` directive for grouping
- `flush_handlers` for immediate execution

---

## What Are Handlers?

**Handlers** are special tasks that only run when **notified** by another task.

```yaml
tasks:
  - name: Update nginx config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: Restart nginx       # Trigger handler

handlers:
  - name: Restart nginx         # Only runs if notified
    service:
      name: nginx
      state: restarted
```

---

## Why Use Handlers?

### Without handlers (inefficient):

```yaml
- name: Update config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf

- name: Always restart nginx
  service:
    name: nginx
    state: restarted    # Restarts EVERY time!
```

### With handlers (smart):

```yaml
- name: Update config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Restart nginx    # Only if config changed!
```

---

## Handler Benefits

| Benefit | Description |
|---------|-------------|
| **Efficiency** | Only runs when needed |
| **Idempotency** | No unnecessary restarts |
| **Organization** | Separates actions from triggers |
| **Deduplication** | Runs once even if notified multiple times |

---

## Basic Handler Syntax

```yaml
- name: My playbook
  hosts: all

  tasks:
    - name: Update config file
      template:
        src: app.conf.j2
        dest: /etc/app/app.conf
      notify: Restart app        # Trigger by name

  handlers:
    - name: Restart app          # Must match notify
      service:
        name: myapp
        state: restarted
```

---

## Handler Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│                    PLAY EXECUTION                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Task 1  ──► changed ──► notify: Restart nginx         │
│   Task 2  ──► ok      ──► (no notify)                   │
│   Task 3  ──► changed ──► notify: Restart nginx         │
│   Task 4  ──► ok      ──► (no notify)                   │
│                                                          │
│   ─────────────── END OF TASKS ─────────────────        │
│                                                          │
│   Handler: Restart nginx  ──► Runs ONCE                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Key Rule: Handler Runs ONCE

```yaml
tasks:
  - name: Update config 1
    copy: ...
    notify: Restart nginx
    changed_when: true

  - name: Update config 2
    copy: ...
    notify: Restart nginx     # Same handler
    changed_when: true

  - name: Update config 3
    copy: ...
    notify: Restart nginx     # Same handler
    changed_when: true

handlers:
  - name: Restart nginx
    service: name=nginx state=restarted
    # Runs ONCE even though notified 3 times!
```

---

## Handler Only Runs on Change

```yaml
tasks:
  # Task reports "ok" (not changed)
  - name: Ensure package installed
    apt:
      name: nginx
      state: present    # Already installed = "ok"
    notify: Restart nginx

handlers:
  - name: Restart nginx
    service:
      name: nginx
      state: restarted
    # Does NOT run - task didn't change anything
```

> Handler only triggers when task reports **"changed"**

---

## Multiple Handlers

### Notify multiple handlers from one task

```yaml
tasks:
  - name: Deploy application
    copy:
      src: app/
      dest: /opt/app/
    notify:
      - Stop application
      - Clear cache
      - Start application

handlers:
  - name: Stop application
    service: name=myapp state=stopped

  - name: Clear cache
    file: path=/tmp/cache state=absent

  - name: Start application
    service: name=myapp state=started
```

---

## Handler Execution Order

### Handlers run in **definition order**, not notify order!

```yaml
tasks:
  - name: Task notifies B first
    debug: msg="notifying B"
    notify: Handler B
    changed_when: true

  - name: Task notifies A second
    debug: msg="notifying A"
    notify: Handler A
    changed_when: true

handlers:
  - name: Handler A       # Defined first = runs first
    debug: msg="A runs FIRST"

  - name: Handler B       # Defined second = runs second
    debug: msg="B runs SECOND"
```

---

## Handler Order Visual

```
┌─────────────────────────────────────────────────────────┐
│              HANDLER EXECUTION ORDER                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   NOTIFY ORDER:           EXECUTION ORDER:              │
│   ┌─────────────┐         ┌─────────────┐               │
│   │ 1. Handler C│         │ 1. Handler A│ (defined 1st)│
│   │ 2. Handler A│   ───►  │ 2. Handler B│ (defined 2nd)│
│   │ 3. Handler B│         │ 3. Handler C│ (defined 3rd)│
│   └─────────────┘         └─────────────┘               │
│                                                          │
│   Handlers run in DEFINITION order, not notify order!   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Handler Chaining

### One handler can notify another handler

```yaml
tasks:
  - name: Update SSL certificate
    copy:
      src: cert.pem
      dest: /etc/ssl/cert.pem
    notify: Reload nginx

handlers:
  - name: Reload nginx
    service:
      name: nginx
      state: reloaded
    notify: Verify nginx       # Chain to next handler

  - name: Verify nginx
    command: curl -s http://localhost/health
```

---

## The listen Directive

### Group multiple handlers under one event

```yaml
tasks:
  - name: Deploy application
    copy:
      src: app/
      dest: /opt/app/
    notify: restart web stack    # One event name

handlers:
  # All these handlers "listen" to the same event
  - name: Restart nginx
    service: name=nginx state=restarted
    listen: restart web stack

  - name: Restart php-fpm
    service: name=php-fpm state=restarted
    listen: restart web stack

  - name: Clear opcache
    command: /usr/bin/cachetool opcache:reset
    listen: restart web stack
```

---

## listen Visual

```
┌─────────────────────────────────────────────────────────┐
│                    listen DIRECTIVE                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Task: notify: "restart web stack"                     │
│                     │                                    │
│                     ▼                                    │
│         ┌──────────────────────┐                        │
│         │  restart web stack   │  (event)               │
│         └──────────────────────┘                        │
│            │         │         │                         │
│            ▼         ▼         ▼                         │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐                   │
│   │ Restart │ │ Restart │ │  Clear  │                   │
│   │  nginx  │ │ php-fpm │ │  cache  │                   │
│   └─────────┘ └─────────┘ └─────────┘                   │
│   listen:     listen:     listen:                       │
│   restart     restart     restart                       │
│   web stack   web stack   web stack                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## notify vs listen

| Method | Syntax | Use Case |
|--------|--------|----------|
| **notify** (list) | `notify: [A, B, C]` | Explicit list |
| **listen** | `listen: event` | Grouped handlers |

```yaml
# notify: List all handlers
notify:
  - Handler A
  - Handler B
  - Handler C

# listen: One event, multiple listeners
notify: restart services
# + handlers with 'listen: restart services'
```

> **listen** is cleaner when many handlers share an event

---

## flush_handlers

### Force handlers to run immediately

```yaml
tasks:
  - name: Install nginx
    apt:
      name: nginx
      state: present
    notify: Start nginx

  # Force handler to run NOW
  - name: Flush handlers
    meta: flush_handlers

  - name: Health check (needs nginx running)
    uri:
      url: http://localhost/health
      status_code: 200
```

---

## Default vs Flush

```
┌─────────────────────────────────────────────────────────┐
│                 DEFAULT BEHAVIOR                         │
├─────────────────────────────────────────────────────────┤
│   Task 1 ──► notify                                      │
│   Task 2                                                 │
│   Task 3                                                 │
│   ────────── END ──────────                             │
│   Handler runs HERE                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              WITH flush_handlers                         │
├─────────────────────────────────────────────────────────┤
│   Task 1 ──► notify                                      │
│   meta: flush_handlers                                   │
│   Handler runs HERE ◄──────                              │
│   Task 2 (can depend on handler)                        │
│   Task 3                                                 │
└─────────────────────────────────────────────────────────┘
```

---

## When to Use flush_handlers

| Scenario | Example |
|----------|---------|
| Service must be running | Health check after start |
| Task depends on handler | App needs DB running first |
| Order matters | Config loaded before test |

```yaml
- name: Start database
  service: name=mysql state=started
  notify: Wait for DB

- meta: flush_handlers    # Wait completes

- name: Run migrations    # Safe to proceed
  command: /opt/app/migrate
```

---

## Handlers with Conditions

```yaml
handlers:
  - name: Restart nginx
    service:
      name: nginx
      state: restarted
    when: ansible_os_family == "Debian"

  - name: Restart nginx (RedHat)
    service:
      name: nginx
      state: restarted
    when: ansible_os_family == "RedHat"
```

> Handlers support `when` clauses like regular tasks

---

## Real-World Pattern: Web Deployment

```yaml
tasks:
  - name: Deploy application code
    synchronize:
      src: app/
      dest: /var/www/app/
    notify: reload web stack

  - name: Update nginx config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/sites-enabled/app
    notify: reload web stack

handlers:
  - name: Validate nginx
    command: nginx -t
    listen: reload web stack

  - name: Reload nginx
    service: name=nginx state=reloaded
    listen: reload web stack

  - name: Clear cache
    command: redis-cli FLUSHDB
    listen: reload web stack
```

---

## Common Mistakes

### Mistake 1: Handler name mismatch

```yaml
tasks:
  - name: Update config
    template: ...
    notify: Restart Nginx    # Capital N

handlers:
  - name: Restart nginx      # Lowercase n - NO MATCH!
```

### Mistake 2: Forgetting handlers run at end

```yaml
- name: Start service
  notify: Start app

- name: Check service        # Runs BEFORE handler!
  uri: url=http://localhost
```

---

## Handler Best Practices

| Practice | Description |
|----------|-------------|
| Consistent naming | `Restart nginx`, `Reload nginx` |
| Use listen for groups | One event, multiple handlers |
| flush_handlers when needed | For dependent tasks |
| Keep handlers simple | Single responsibility |
| Define in logical order | They run in definition order |

---

## Quick Reference

```yaml
# Basic handler
notify: Handler name

# Multiple handlers
notify:
  - Handler A
  - Handler B

# Listen (grouped handlers)
listen: event name

# Flush handlers immediately
meta: flush_handlers

# Handler with condition
handlers:
  - name: My handler
    service: ...
    when: condition
```

---

## Key Takeaways

| Concept | Description |
|---------|-------------|
| `notify` | Triggers handler on change |
| Runs once | Even if notified multiple times |
| End of play | Default execution time |
| Definition order | Handlers run in order defined |
| `listen` | Group handlers under one event |
| `flush_handlers` | Force immediate execution |
| Conditions | Handlers support `when` |

---

## Hands-on Exercises

```bash
cd chapter-06-handlers

# Basic handlers
ansible-playbook 01-handler-basics.yml

# Multiple handlers
ansible-playbook 02-multiple-handlers.yml

# Listen directive
ansible-playbook 03-listen-handlers.yml

# Flush handlers
ansible-playbook 04-flush-handlers.yml
```

---

## Summary

### What We Learned:

- Handlers run only when tasks report "changed"
- Handlers run **once** at **end of play**
- Execution follows **definition order**
- `listen` groups multiple handlers
- `flush_handlers` forces immediate execution
- Handlers support conditions with `when`

---

## Next Chapter

# Chapter 07
## Tags

- Tagging tasks and plays
- Running specific tags
- Skipping tags
- Special tags: always, never

---

# Thank You!

### Questions?

**Key Takeaway:**
> "Handlers ensure actions run only when changes occur!"

**Resources:**
- [Ansible Handlers Docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html)

---
