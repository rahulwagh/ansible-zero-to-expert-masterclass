# Chapter 05 - Loops

Master iteration in Ansible - process lists, dictionaries, and complex data structures.

## What You'll Learn

- Basic `loop` with lists and dictionaries
- Legacy `with_*` directives
- `loop_control` options (label, index_var, pause)
- Nested loops and special loops
- Register with loops

---

## Quick Start

```bash
cd chapter-05-loops
ansible all -m ping
ansible-playbook 01-loop-basics.yml
```

---

## Playbooks

| # | Playbook | Concepts Covered |
|---|----------|------------------|
| 01 | loop-basics.yml | Basic loop, list of dicts, with_items |
| 02 | loop-with-dict.yml | dict2items, with_dict, nested dicts |
| 03 | loop-control.yml | label, index_var, pause, extended |
| 04 | loop-advanced.yml | Nested loops, register, until, fileglob |

---

## Run the Playbooks

### Playbook 01: Loop Basics

```bash
ansible-playbook 01-loop-basics.yml
```

**Covers:** Simple lists, list of dicts, with_items, loop with when

---

### Playbook 02: Loop with Dict

```bash
ansible-playbook 02-loop-with-dict.yml
```

**Covers:** dict2items filter, with_dict, nested dicts, keys/values

---

### Playbook 03: Loop Control

```bash
ansible-playbook 03-loop-control.yml
```

**Covers:** label (hide secrets), index_var, extended info, pause

---

### Playbook 04: Advanced Loops

```bash
ansible-playbook 04-loop-advanced.yml
```

**Covers:** Nested loops (product), register, with_fileglob, until/retry

---

## Quick Reference

### Basic Loop

```yaml
# Simple list
loop:
  - nginx
  - mysql
  - redis

# From variable
loop: "{{ packages }}"

# List of dicts
loop:
  - name: alice
    uid: 1001
  - name: bob
    uid: 1002
```

### Loop over Dictionary

```yaml
vars:
  ports:
    nginx: 80
    mysql: 3306

# Using dict2items filter
loop: "{{ ports | dict2items }}"
# Access: item.key, item.value

# Legacy with_dict
with_dict: "{{ ports }}"
```

### Loop Control

```yaml
loop: "{{ users }}"
loop_control:
  label: "{{ item.name }}"    # What to show in output
  index_var: idx              # Custom index variable
  pause: 2                    # Seconds between iterations
  extended: true              # Access ansible_loop.*
```

### Extended Loop Variables

| Variable | Description |
|----------|-------------|
| `ansible_loop.index` | Current iteration (1-based) |
| `ansible_loop.index0` | Current iteration (0-based) |
| `ansible_loop.first` | True if first iteration |
| `ansible_loop.last` | True if last iteration |
| `ansible_loop.length` | Total number of items |

### Nested Loops

```yaml
# Modern: product filter
loop: "{{ users | product(groups) | list }}"
# Access: item.0, item.1

# Legacy: with_nested
with_nested:
  - "{{ users }}"
  - "{{ groups }}"
```

### Register with Loops

```yaml
- name: Check files
  stat:
    path: "{{ item }}"
  loop:
    - /etc/hosts
    - /etc/passwd
  register: results

- name: Use results
  debug:
    msg: "{{ item.stat.exists }}"
  loop: "{{ results.results }}"
```

### Until (Retry Loop)

```yaml
- name: Wait for service
  uri:
    url: http://localhost:8080/health
  register: result
  until: result.status == 200
  retries: 10
  delay: 5
```

---

## Loop vs with_* Comparison

| Modern (loop) | Legacy (with_*) |
|---------------|-----------------|
| `loop: "{{ list }}"` | `with_items: "{{ list }}"` |
| `loop: "{{ dict \| dict2items }}"` | `with_dict: "{{ dict }}"` |
| `loop: "{{ a \| product(b) \| list }}"` | `with_nested: [a, b]` |
| `loop: "{{ range(1,6) \| list }}"` | `with_sequence: start=1 end=5` |

**Recommendation:** Use `loop` for new playbooks. `with_*` still works but `loop` is preferred.

---

## Key Takeaways

1. **loop** - Preferred way to iterate
2. **dict2items** - Convert dict to list for looping
3. **loop_control: label** - Hide sensitive data in output
4. **extended: true** - Access index, first, last, length
5. **register** - Results stored in `.results` array
6. **until** - Retry until condition is met
