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

# Chapter 05
# Loops

### Master Iteration in Ansible

---

## What You'll Learn

- Basic `loop` with lists and dictionaries
- Legacy `with_*` directives
- `loop_control` options (label, index, pause)
- Nested loops and special loops
- Register with loops
- Until/retry loops

---

## Why Use Loops?

### Without loops (repetitive):
```yaml
- name: Install nginx
  apt: name=nginx state=present
- name: Install mysql
  apt: name=mysql state=present
- name: Install redis
  apt: name=redis state=present
```

### With loops (clean):
```yaml
- name: Install packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - mysql
    - redis
```

---

## Basic Loop Syntax

```yaml
vars:
  packages:
    - nginx
    - git
    - curl
    - vim

tasks:
  - name: Install packages
    debug:
      msg: "Installing {{ item }}"
    loop: "{{ packages }}"
```

> `item` is the **magic variable** containing current loop value

---

## Loop Flow Visual

```
┌─────────────────────────────────────────────────────────┐
│                     LOOP EXECUTION                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   loop:                                                  │
│     - nginx     ──► item = "nginx"   ──► Task runs      │
│     - mysql     ──► item = "mysql"   ──► Task runs      │
│     - redis     ──► item = "redis"   ──► Task runs      │
│                                                          │
│   Task repeats for EACH item in the list                │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Loop Over List of Dictionaries

```yaml
vars:
  users:
    - name: alice
      uid: 1001
      groups: developers
    - name: bob
      uid: 1002
      groups: admins

tasks:
  - name: Create users
    debug:
      msg: "Creating {{ item.name }} (UID: {{ item.uid }})"
    loop: "{{ users }}"
```

> Access dict keys with `item.key_name`

---

## Loop with Condition

### Filter items using `when`

```yaml
vars:
  users:
    - name: alice
      groups: developers
    - name: bob
      groups: admins
    - name: charlie
      groups: developers

tasks:
  - name: Only developers
    debug:
      msg: "{{ item.name }} is a developer"
    loop: "{{ users }}"
    when: item.groups == "developers"
```

---

## Loop Over Dictionary

### Problem: Can't loop directly over a dict

```yaml
vars:
  app_ports:
    nginx: 80
    mysql: 3306
    redis: 6379
```

### Solution: Use `dict2items` filter

```yaml
- name: Show app ports
  debug:
    msg: "{{ item.key }}: port {{ item.value }}"
  loop: "{{ app_ports | dict2items }}"
```

---

## dict2items Visual

```
┌─────────────────────────────────────────────────────────┐
│                    dict2items                            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   BEFORE (dictionary):          AFTER (list of dicts):  │
│   ┌─────────────────┐           ┌─────────────────────┐ │
│   │ nginx: 80       │           │ - key: nginx        │ │
│   │ mysql: 3306     │  ──────►  │   value: 80         │ │
│   │ redis: 6379     │           │ - key: mysql        │ │
│   └─────────────────┘           │   value: 3306       │ │
│                                 │ - key: redis        │ │
│                                 │   value: 6379       │ │
│                                 └─────────────────────┘ │
│                                                          │
│   Access: item.key, item.value                          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Nested Dictionary

```yaml
vars:
  environments:
    production:
      url: "https://prod.example.com"
      debug: false
    staging:
      url: "https://stage.example.com"
      debug: true

tasks:
  - name: Show environment configs
    debug:
      msg: "{{ item.key }}: {{ item.value.url }}"
    loop: "{{ environments | dict2items }}"
```

---

## Dictionary Keys and Values Only

```yaml
vars:
  app_ports:
    nginx: 80
    mysql: 3306
    redis: 6379

tasks:
  # Keys only
  - name: Show app names
    debug:
      msg: "App: {{ item }}"
    loop: "{{ app_ports.keys() | list }}"

  # Values only
  - name: Show ports
    debug:
      msg: "Port: {{ item }}"
    loop: "{{ app_ports.values() | list }}"
```

---

## loop_control: label

### Problem: Secrets exposed in output!

```
TASK [Create user] ***
ok: [server] => (item={'name': 'alice', 'password': 'secret123'})
```

### Solution: Use `label` to hide sensitive data

```yaml
- name: Create user
  debug:
    msg: "Creating {{ item.name }}"
  loop: "{{ users }}"
  loop_control:
    label: "{{ item.name }}"
```

**Output:** `ok: [server] => (item=alice)`

---

## loop_control: index_var

### Get custom index variable

```yaml
- name: Show with custom index
  debug:
    msg: "{{ my_idx }}: {{ item }}"
  loop:
    - first
    - second
    - third
  loop_control:
    index_var: my_idx
```

**Output:**
```
"0: first"
"1: second"
"2: third"
```

> Note: `index_var` is **0-based**

---

## loop_control: extended

### Unlock full loop information

```yaml
- name: Full loop details
  debug:
    msg: "{{ ansible_loop.index }}/{{ ansible_loop.length }}: {{ item }}"
  loop:
    - nginx
    - mysql
    - redis
  loop_control:
    extended: true
```

**Output:**
```
"1/3: nginx"
"2/3: mysql"
"3/3: redis"
```

---

## Extended Loop Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ansible_loop.index` | Current position (1-based) | 1, 2, 3 |
| `ansible_loop.index0` | Current position (0-based) | 0, 1, 2 |
| `ansible_loop.first` | Is first item? | true/false |
| `ansible_loop.last` | Is last item? | true/false |
| `ansible_loop.length` | Total items | 3 |
| `ansible_loop.revindex` | Reverse index (1-based) | 3, 2, 1 |

---

## Extended Loop Example

```yaml
- name: Show loop info
  debug:
    msg: |
      Item: {{ item }}
      Index: {{ ansible_loop.index }}
      First: {{ ansible_loop.first }}
      Last: {{ ansible_loop.last }}
  loop:
    - apple
    - banana
    - cherry
  loop_control:
    extended: true
```

---

## Why extended: true is Not Default

```
┌─────────────────────────────────────────────────────────┐
│            WHY ISN'T extended: true DEFAULT?            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   PERFORMANCE                                            │
│                                                          │
│   Without extended:                                      │
│   └── Just tracks: item                                 │
│                                                          │
│   With extended: true                                    │
│   └── Calculates: index, index0, first, last,           │
│                   length, revindex, revindex0...        │
│                                                          │
│   For 1000 items = 1000 extra calculations              │
│                                                          │
│   Only enable when you NEED it!                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## loop_control: pause

### Add delay between iterations

```yaml
- name: Process with delay
  debug:
    msg: "Processing {{ item }}"
  loop:
    - task1
    - task2
    - task3
  loop_control:
    pause: 2    # 2 seconds between each
```

> Useful for rate limiting or API throttling

---

## Combining loop_control Options

```yaml
- name: Full control
  debug:
    msg: "[{{ idx }}] {{ item.name }} {{ 'LAST!' if ansible_loop.last else '' }}"
  loop: "{{ users }}"
  loop_control:
    label: "{{ item.name }}"     # Hide secrets
    index_var: idx               # Custom index
    extended: true               # Access ansible_loop.*
    pause: 1                     # Delay between items
```

---

## Nested Loops: product Filter

### Loop over combinations of two lists

```yaml
vars:
  users:
    - alice
    - bob
  groups:
    - developers
    - testers

tasks:
  - name: Add users to groups
    debug:
      msg: "Add {{ item.0 }} to {{ item.1 }}"
    loop: "{{ users | product(groups) | list }}"
```

---

## Nested Loop Visual

```
┌─────────────────────────────────────────────────────────┐
│                  NESTED LOOP (product)                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   users: [alice, bob]    groups: [dev, test]            │
│                                                          │
│   users | product(groups) | list                        │
│                                                          │
│   Result:                                                │
│   ┌────────────────────────────────────────┐            │
│   │ (alice, dev)   ──► item.0 = alice      │            │
│   │                    item.1 = dev        │            │
│   │ (alice, test)                          │            │
│   │ (bob, dev)                             │            │
│   │ (bob, test)                            │            │
│   └────────────────────────────────────────┘            │
│                                                          │
│   Total: 2 users × 2 groups = 4 iterations              │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Nested Loop Output

```yaml
loop: "{{ users | product(groups) | list }}"
```

**Output:**
```
"Add alice to developers"
"Add alice to testers"
"Add bob to developers"
"Add bob to testers"
```

> Access items with `item.0` and `item.1`

---

## zip Filter: Parallel Lists

### Combine lists element by element

```yaml
- name: Parallel lists
  debug:
    msg: "{{ item.0 }} = {{ item.1 }}"
  loop: "{{ ['a', 'b', 'c'] | zip([1, 2, 3]) | list }}"
```

**Output:**
```
"a = 1"
"b = 2"
"c = 3"
```

---

## zip vs product

```
┌─────────────────────────────────────────────────────────┐
│                  zip vs product                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   zip: Pairs by position (parallel)                     │
│   ┌────────────────────────────────────────┐            │
│   │ [a, b, c] + [1, 2, 3]                  │            │
│   │ Result: (a,1), (b,2), (c,3)            │            │
│   │ Count: 3 items                          │            │
│   └────────────────────────────────────────┘            │
│                                                          │
│   product: All combinations (cartesian)                 │
│   ┌────────────────────────────────────────┐            │
│   │ [a, b, c] × [1, 2, 3]                  │            │
│   │ Result: (a,1),(a,2),(a,3),(b,1)...     │            │
│   │ Count: 9 items (3 × 3)                 │            │
│   └────────────────────────────────────────┘            │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## range Filter: Generate Numbers

```yaml
# Modern approach
- name: Count 1 to 5
  debug:
    msg: "Count: {{ item }}"
  loop: "{{ range(1, 6) | list }}"
```

**Output:**
```
"Count: 1"
"Count: 2"
"Count: 3"
"Count: 4"
"Count: 5"
```

> Note: `range(1, 6)` = 1 to 5 (end is exclusive)

---

## Register with Loops

### Capture ALL results from a loop

```yaml
- name: Check multiple files
  stat:
    path: "{{ item }}"
  loop:
    - /etc/hosts
    - /etc/passwd
    - /nonexistent
  register: file_checks

- name: Show results
  debug:
    msg: "{{ item.item }}: exists={{ item.stat.exists }}"
  loop: "{{ file_checks.results }}"
```

---

## Register with Loop Visual

```
┌─────────────────────────────────────────────────────────┐
│                REGISTER WITH LOOPS                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Task loops 3 times ──► register: file_checks          │
│                                                          │
│   file_checks:                                           │
│   ┌─────────────────────────────────────────────────┐   │
│   │ results:                                        │   │
│   │   - item: /etc/hosts                            │   │
│   │     stat: { exists: true, size: 123 }           │   │
│   │   - item: /etc/passwd                           │   │
│   │     stat: { exists: true, size: 456 }           │   │
│   │   - item: /nonexistent                          │   │
│   │     stat: { exists: false }                     │   │
│   └─────────────────────────────────────────────────┘   │
│                                                          │
│   Access with: file_checks.results                      │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Filter Loop Results

### Use selectattr to filter

```yaml
- name: Check files
  stat:
    path: "{{ item }}"
  loop:
    - /etc/hosts
    - /etc/passwd
    - /nonexistent
  register: file_checks

# Only show existing files
- name: Existing files only
  debug:
    msg: "Found: {{ item.item }}"
  loop: "{{ file_checks.results | selectattr('stat.exists', 'true') | list }}"
```

---

## Until Loop (Retry)

### Retry until condition is met

```yaml
- name: Wait for service
  uri:
    url: http://localhost:8080/health
  register: result
  until: result.status == 200
  retries: 10        # Try up to 10 times
  delay: 5           # Wait 5 seconds between tries
```

> Great for waiting for services to start!

---

## Until Loop Visual

```
┌─────────────────────────────────────────────────────────┐
│                     UNTIL LOOP                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   until: result.status == 200                           │
│   retries: 10                                            │
│   delay: 5                                               │
│                                                          │
│   Attempt 1 ──► status=503 ──► Wait 5s                  │
│   Attempt 2 ──► status=503 ──► Wait 5s                  │
│   Attempt 3 ──► status=200 ──► SUCCESS!                 │
│                                                          │
│   result.attempts = 3                                    │
│                                                          │
│   If all 10 fail ──► Task FAILS                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Until Example: Random Number

```yaml
- name: Get number > 7
  shell: "echo $((RANDOM % 10))"
  register: result
  until: result.stdout | int > 7
  retries: 5
  delay: 1

- name: Show result
  debug:
    msg: "Got {{ result.stdout }} after {{ result.attempts }} attempts"
```

---

## Legacy with_* Directives

### Still work, but `loop` is preferred

| Modern (loop) | Legacy (with_*) |
|---------------|-----------------|
| `loop: "{{ list }}"` | `with_items: "{{ list }}"` |
| `loop: "{{ dict \| dict2items }}"` | `with_dict: "{{ dict }}"` |
| `loop: "{{ a \| product(b) \| list }}"` | `with_nested: [a, b]` |
| `loop: "{{ range(1,6) \| list }}"` | `with_sequence: start=1 end=5` |

---

## with_items (Legacy)

```yaml
# Legacy
- name: Install packages
  apt:
    name: "{{ item }}"
  with_items:
    - nginx
    - mysql
    - redis

# Modern equivalent
- name: Install packages
  apt:
    name: "{{ item }}"
  loop:
    - nginx
    - mysql
    - redis
```

---

## with_dict (Legacy)

```yaml
vars:
  ports:
    nginx: 80
    mysql: 3306

# Legacy
- name: Show ports
  debug:
    msg: "{{ item.key }}: {{ item.value }}"
  with_dict: "{{ ports }}"

# Modern equivalent
- name: Show ports
  debug:
    msg: "{{ item.key }}: {{ item.value }}"
  loop: "{{ ports | dict2items }}"
```

---

## with_fileglob

### Loop over files matching a pattern

```yaml
- name: Find all YAML files
  debug:
    msg: "Found: {{ item | basename }}"
  with_fileglob:
    - "*.yml"
    - "*.yaml"
```

> Runs on **control node**, not remote hosts

---

## with_lines

### Loop over command output lines

```yaml
- name: Process passwd file
  debug:
    msg: "Line: {{ item }}"
  with_lines: "head -3 /etc/passwd"
```

**Output:**
```
"Line: root:x:0:0:root:/root:/bin/bash"
"Line: daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin"
"Line: bin:x:2:2:bin:/bin:/usr/sbin/nologin"
```

---

## Loop Decision Tree

```
┌─────────────────────────────────────────────────────────┐
│              WHICH LOOP TO USE?                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Simple list?           ──► loop: "{{ list }}"         │
│                                                          │
│   Dictionary?            ──► loop + dict2items          │
│                                                          │
│   Two lists combined?    ──► loop + product             │
│                                                          │
│   Two lists paired?      ──► loop + zip                 │
│                                                          │
│   Need index/first/last? ──► loop_control: extended     │
│                                                          │
│   Hide sensitive data?   ──► loop_control: label        │
│                                                          │
│   Retry until success?   ──► until + retries + delay    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Key Takeaways

| Concept | Purpose |
|---------|---------|
| `loop` | Iterate over lists |
| `item` | Current loop value |
| `dict2items` | Convert dict for looping |
| `label` | Hide secrets in output |
| `extended: true` | Access index, first, last |
| `product` | All combinations (nested) |
| `zip` | Parallel lists |
| `until` | Retry until condition met |
| `register` | Results in `.results` array |

---

## Hands-on Exercises

```bash
cd chapter-05-loops

# Basic loops
ansible-playbook 01-loop-basics.yml

# Dictionary loops
ansible-playbook 02-loop-with-dict.yml

# Loop control options
ansible-playbook 03-loop-control.yml

# Advanced loops
ansible-playbook 04-loop-advanced.yml
```

---

## Summary

### What We Learned:

- Basic `loop` with lists and dicts
- `dict2items` for dictionary iteration
- `loop_control`: label, index_var, extended, pause
- Nested loops with `product` filter
- Parallel iteration with `zip`
- `register` captures all results in `.results`
- `until` for retry loops
- Legacy `with_*` vs modern `loop`

---

## Next Chapter

# Chapter 06
## Handlers

- Triggering actions on changes
- Handler execution order
- Multiple handlers
- Flushing handlers

---

# Thank You!

### Questions?

**Key Takeaway:**
> "Use `loop` for iteration, `loop_control` for customization!"

**Resources:**
- [Ansible Loops Docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html)
- [Loop Control](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html#adding-controls-to-loops)

---
