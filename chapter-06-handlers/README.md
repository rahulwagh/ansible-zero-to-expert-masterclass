# Chapter 06 - Handlers

Master handlers in Ansible - trigger actions only when changes occur.

## What You'll Learn

- What handlers are and why use them
- Basic handler syntax with `notify`
- Handler execution order
- Multiple handlers and chaining
- `listen` directive for grouping handlers
- `flush_handlers` for immediate execution
- Handlers with conditions

---

## Quick Start

```bash
cd chapter-06-handlers
ansible all -m ping
ansible-playbook 01-handler-basics.yml
```

---

## Playbooks

| # | Playbook | Concepts Covered |
|---|----------|------------------|
| 01 | handler-basics.yml | Basic notify, handler runs once, execution order |
| 02 | multiple-handlers.yml | Multiple handlers, notify list, handler chaining |
| 03 | listen-handlers.yml | listen directive, grouping handlers |
| 04 | flush-handlers.yml | meta: flush_handlers, immediate execution |

---

## Run the Playbooks

### Playbook 01: Handler Basics

```bash
ansible-playbook 01-handler-basics.yml
```

**Covers:** Basic notify, handlers run at end, runs only once

---

### Playbook 02: Multiple Handlers

```bash
ansible-playbook 02-multiple-handlers.yml
```

**Covers:** Multiple handlers, execution order, handler chaining

---

### Playbook 03: Listen Handlers

```bash
ansible-playbook 03-listen-handlers.yml
```

**Covers:** listen directive, grouping multiple handlers

---

### Playbook 04: Flush Handlers

```bash
ansible-playbook 04-flush-handlers.yml
```

**Covers:** meta: flush_handlers, immediate execution, conditions

---

## Quick Reference

### Basic Handler

```yaml
tasks:
  - name: Update config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: Restart nginx

handlers:
  - name: Restart nginx
    service:
      name: nginx
      state: restarted
```

### Key Points

| Concept | Description |
|---------|-------------|
| `notify` | Triggers a handler when task reports "changed" |
| Handler runs once | Even if notified multiple times |
| Runs at end | Handlers execute at end of play |
| Definition order | Handlers run in order defined, not notify order |

---

### Multiple Handlers

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
    service:
      name: myapp
      state: stopped

  - name: Clear cache
    file:
      path: /tmp/cache
      state: absent

  - name: Start application
    service:
      name: myapp
      state: started
```

---

### Listen Directive

```yaml
tasks:
  - name: Update web config
    template:
      src: config.j2
      dest: /etc/app/config
    notify: restart web stack    # One notify

handlers:
  # Multiple handlers respond to same event
  - name: Restart nginx
    service:
      name: nginx
      state: restarted
    listen: restart web stack

  - name: Restart php-fpm
    service:
      name: php-fpm
      state: restarted
    listen: restart web stack

  - name: Clear cache
    command: /usr/bin/clear-cache
    listen: restart web stack
```

**Benefit:** One `notify` triggers multiple handlers!

---

### Flush Handlers

```yaml
tasks:
  - name: Install nginx
    apt:
      name: nginx
      state: present
    notify: Start nginx

  # Force handlers to run NOW
  - name: Ensure nginx is running
    meta: flush_handlers

  - name: Health check (needs nginx running)
    uri:
      url: http://localhost/health
      status_code: 200

handlers:
  - name: Start nginx
    service:
      name: nginx
      state: started
```

**Use case:** When next task depends on handler completing first.

---

### Handler with Condition

```yaml
handlers:
  - name: Restart nginx
    service:
      name: nginx
      state: restarted
    when: ansible_os_family == "Debian"
```

---

## Handler Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│                    PLAY EXECUTION                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Task 1  ──► changed ──► notify: Restart nginx         │
│   Task 2  ──► ok                                         │
│   Task 3  ──► changed ──► notify: Restart nginx         │
│   Task 4  ──► ok                                         │
│                                                          │
│   ─────────── END OF TASKS ───────────                  │
│                                                          │
│   Handler: Restart nginx  ──► Runs ONCE                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## notify vs listen Comparison

| Feature | notify | listen |
|---------|--------|--------|
| Syntax | `notify: handler_name` | `listen: event_name` |
| One-to-one | Task → Handler | Event → Multiple handlers |
| Use case | Simple triggers | Group related handlers |
| Flexibility | Less flexible | More flexible |

```yaml
# notify: Must list all handlers
notify:
  - Handler A
  - Handler B
  - Handler C

# listen: One event, many handlers
notify: my event
# Handlers with 'listen: my event' all run
```

---

## When to Use flush_handlers

| Scenario | Use flush_handlers? |
|----------|---------------------|
| Service must be running for next task | Yes |
| Health check after service restart | Yes |
| Task depends on handler completing | Yes |
| Normal end-of-play execution is fine | No |

---

## Key Takeaways

1. **notify** - Triggers handler when task changes
2. **Runs once** - Handler runs once even if notified multiple times
3. **End of play** - Handlers run at end of play by default
4. **Definition order** - Handlers run in order defined
5. **listen** - Group multiple handlers under one event
6. **flush_handlers** - Force immediate handler execution
7. **Conditions** - Handlers support `when` clauses

---

## Common Patterns

### Pattern 1: Config Change → Service Restart

```yaml
- name: Update nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Restart nginx
```

### Pattern 2: Validate Before Restart

```yaml
handlers:
  - name: Validate nginx config
    command: nginx -t
    notify: Restart nginx

  - name: Restart nginx
    service:
      name: nginx
      state: restarted
```

### Pattern 3: Grouped Services

```yaml
tasks:
  - name: Deploy app
    copy:
      src: app/
      dest: /opt/app/
    notify: restart stack

handlers:
  - name: Restart nginx
    service: name=nginx state=restarted
    listen: restart stack

  - name: Restart app
    service: name=myapp state=restarted
    listen: restart stack
```
