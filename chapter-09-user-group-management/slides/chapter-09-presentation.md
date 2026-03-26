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

# Chapter 09
# User & Group Management

### Automate Linux Users, Groups & SSH Keys with Ansible

---

## What You'll Learn

- Managing user accounts with the `user` module
- Managing groups with the `group` module
- Controlling SSH access with `authorized_key`
- System users vs regular users
- Real-world: provisioning a developer team

---

## Why Automate User Management?

**Manual approach — error-prone and slow:**

```bash
# Done on every server, by hand
useradd -m -u 2001 -s /bin/bash -c "Alice Dev" alice
usermod -aG developers,devops alice
mkdir -p /home/alice/.ssh
echo "ssh-rsa AAAA..." >> /home/alice/.ssh/authorized_keys
chmod 700 /home/alice/.ssh
chmod 600 /home/alice/.ssh/authorized_keys
```

- Repeated manually on every server
- No consistency guarantee across hosts
- Easy to miss a step or get permissions wrong

---

## Why Automate User Management?

**Ansible approach — idempotent and scalable:**

```yaml
- user:
    name: alice
    uid: 2001
    shell: /bin/bash
    groups: [developers, devops]
    append: true

- authorized_key:
    user: alice
    key: "ssh-rsa AAAA..."
```

> Run once against 1 server or 1000 — same result, zero drift

---

## The `user` Module

```yaml
- name: Create a user
  user:
    name: alice             # username (required)
    uid: 2001               # specific UID
    comment: "Alice Dev"    # GECOS / description
    shell: /bin/bash        # login shell
    home: /home/alice       # home directory
    create_home: true       # create home dir (default: true)
    password: "{{ hash }}"  # pre-hashed password
    update_password: on_create
    groups: [developers]    # supplementary groups
    append: true            # add to groups (don't replace)
    state: present          # present | absent
```

> The `user` module is **idempotent** — safe to run multiple times

---

## Creating Users — Examples

```yaml
# Basic user
- user:
    name: alice
    state: present

# User with full options
- user:
    name: bob
    uid: 2001
    shell: /bin/bash
    comment: "Bob the Builder"
    create_home: true
    state: present

# System / service account
- user:
    name: apprunner
    system: true              # UID < 1000
    shell: /usr/sbin/nologin  # no interactive login
    create_home: false
    state: present
```

---

## Regular User vs System User

| Property | Regular User | System User |
|----------|-------------|-------------|
| UID range | ≥ 1000 | < 1000 |
| Home dir | `/home/username` | Usually none |
| Login shell | `/bin/bash` | `/usr/sbin/nologin` |
| Purpose | Human accounts | Services / daemons |
| Ansible | `system: false` | `system: true` |

> **System users** are for background services — they cannot log in interactively

---

## Setting Passwords Safely

**Never store plaintext passwords.** Use the `password_hash` filter:

```yaml
vars:
  raw_password: "MySecret123"

tasks:
  - name: Create user with hashed password
    user:
      name: alice
      password: "{{ raw_password | password_hash('sha512') }}"
      update_password: on_create   # only set on first creation
```

Generate a hash offline:

```bash
python3 -c "from passlib.hash import sha512_crypt; \
  print(sha512_crypt.using(rounds=5000).hash('MySecret123'))"
```

> **Best practice:** Store passwords in **Ansible Vault**, not plain vars

---

## Removing a User

```yaml
- name: Remove user and their home directory
  user:
    name: alice
    state: absent
    remove: true    # also deletes /home/alice and mail spool
```

**Without `remove: true`** — user account deleted, home directory left behind

**With `remove: true`** — user account AND home directory deleted

> Always confirm before running with `--check` flag first

---

## The `group` Module

```yaml
- name: Create a group
  group:
    name: developers  # group name (required)
    gid: 3001         # specific GID
    system: false     # true = system group (GID < 1000)
    state: present    # present | absent
```

```yaml
# Create multiple groups in a loop
- group:
    name: "{{ item.name }}"
    gid: "{{ item.gid }}"
    state: present
  loop:
    - { name: developers, gid: 3001 }
    - { name: devops,     gid: 3002 }
    - { name: deployment, gid: 3003 }
```

---

## Adding Users to Groups

```yaml
# SAFE — append: true keeps existing group memberships
- user:
    name: bob
    groups:
      - developers
      - devops
    append: true

# DESTRUCTIVE — append: false replaces ALL groups
- user:
    name: bob
    groups:
      - developers
    append: false   # bob loses ALL other group memberships!
```

> **Always use `append: true`** unless you specifically need to replace groups

---

## The `authorized_key` Module

```yaml
- name: Add SSH public key
  authorized_key:
    user: alice                        # username (required)
    key: "ssh-rsa AAAA... user@host"   # public key (required)
    state: present                     # present | absent
    exclusive: false                   # true = remove all OTHER keys
    key_options: "no-port-forwarding"  # SSH key restrictions
```

**Manages entries in `~/.ssh/authorized_keys`**

> Automatically creates `.ssh/` directory with correct permissions

---

## Adding SSH Keys — Three Ways

```yaml
# 1. Inline key string
- authorized_key:
    user: alice
    key: "ssh-rsa AAAA..."

# 2. From a local file using lookup
- authorized_key:
    user: alice
    key: "{{ lookup('file', 'files/alice_id_rsa.pub') }}"

# 3. Multiple keys via loop
- authorized_key:
    user: alice
    key: "{{ item }}"
    state: present
  loop:
    - "ssh-rsa AAAA... alice@laptop"
    - "ssh-ed25519 AAAA... alice@workstation"
```

---

## Exclusive Key Control

```yaml
# Replace ALL keys — only this key is allowed
- authorized_key:
    user: deploy
    key: "ssh-rsa AAAA... approved@security"
    exclusive: true
```

**Use case:** Security hardening — remove any keys that shouldn't be there

```yaml
# Remove a specific key
- authorized_key:
    user: deploy
    key: "ssh-rsa AAAA... oldkey@revoked"
    state: absent
```

---

## Restricting SSH Keys with `key_options`

```yaml
- authorized_key:
    user: backup
    key: "ssh-rsa AAAA... backup@remote"
    key_options: 'no-port-forwarding,no-X11-forwarding,command="/usr/bin/rsync --server"'
```

Generates in `~/.ssh/authorized_keys`:

```
no-port-forwarding,no-X11-forwarding,command="/usr/bin/rsync --server" ssh-rsa AAAA...
```

**Common `key_options`:**

| Option | Purpose |
|--------|---------|
| `no-port-forwarding` | Disable port forwarding |
| `no-X11-forwarding` | Disable X11 forwarding |
| `no-agent-forwarding` | Disable agent forwarding |
| `command="..."` | Force a specific command |
| `from="IP"` | Restrict by source IP |

---

## Practical: Onboard a Developer Team

```yaml
vars:
  team_users:
    - { name: alice, uid: 4001, groups: [developers, devops] }
    - { name: bob,   uid: 4002, groups: [developers] }
    - { name: carol, uid: 4003, groups: [developers, devops, deployment] }

tasks:
  - group:
      name: "{{ item }}"
      state: present
    loop: [developers, devops, deployment]

  - user:
      name: "{{ item.name }}"
      uid: "{{ item.uid }}"
      shell: /bin/bash
      state: present
    loop: "{{ team_users }}"

  - user:
      name: "{{ item.name }}"
      groups: "{{ item.groups }}"
      append: true
    loop: "{{ team_users }}"
```

---

## Practical: SSH Keys + CI Service Account

```yaml
  # Add SSH keys for each team member
  - authorized_key:
      user: "{{ item.name }}"
      key: "{{ item.pub_key }}"
      state: present
    loop: "{{ team_users }}"

  # CI/CD service account — restricted SSH key
  - user:
      name: cibot
      system: true
      groups: [deployment]
      append: true

  - authorized_key:
      user: cibot
      key: "ssh-ed25519 AAAA... cibot@pipeline"
      key_options: 'no-port-forwarding,no-X11-forwarding,no-agent-forwarding'

  # Shared deployment directory with setgid
  - file:
      path: /opt/app/releases
      state: directory
      owner: cibot
      group: deployment
      mode: '2775'
```

---

## Module Comparison

| Module | Manages | Key Options |
|--------|---------|-------------|
| `user` | User accounts | `uid`, `shell`, `home`, `password`, `groups`, `append`, `system` |
| `group` | Groups | `gid`, `system` |
| `authorized_key` | SSH keys in `authorized_keys` | `exclusive`, `key_options`, `path` |

---

## Key Takeaways

1. **`user`** — idempotent; manages accounts end-to-end including password and groups
2. **`group`** — simple but important; always pin `gid` for consistency across hosts
3. **`append: true`** — use this by default to avoid accidental group removal
4. **`authorized_key`** — manages SSH access declaratively; `exclusive: true` for strict control
5. **`password_hash`** — never store plaintext passwords; pair with Ansible Vault
6. **`system: true`** — creates service accounts that cannot log in interactively
7. **`key_options`** — restrict CI/CD and backup keys to specific commands or IPs

---

## Run the Playbooks

```bash
cd chapter-09-user-group-management

# 01 - User basics
ansible-playbook 01-user-basics.yml

# 02 - Group management
ansible-playbook 02-group-management.yml

# 03 - Authorized keys
ansible-playbook 03-authorized-keys.yml

# 04 - Full team onboarding (dry-run first!)
ansible-playbook 04-user-group-practical.yml --check --diff
ansible-playbook 04-user-group-practical.yml
```
