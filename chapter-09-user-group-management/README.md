# Chapter 09 - User & Group Management

Manage Linux users, groups, and SSH authorized keys with the `user`, `group`, and `authorized_key` modules.

## What You'll Learn

- Creating and removing user accounts with the `user` module
- Setting passwords, UIDs, shells, and home directories
- Creating system/service accounts (no-login users)
- Managing groups with the `group` module (GID, system groups)
- Adding users to supplementary groups (`append` vs replace)
- Managing SSH public keys with `authorized_key`
- Restricting SSH keys using `key_options` and `exclusive`
- Real-world: onboarding a developer team end-to-end

---

## Quick Start

```bash
cd chapter-09-user-group-management
ansible all -m ping
ansible-playbook 01-user-basics.yml
```

---

## Directory Structure

```
chapter-09-user-group-management/
├── ansible.cfg
├── inventory/
│   └── hosts.ini
├── files/
│   └── id_rsa_devops.pub         # Sample SSH public key file
├── 01-user-basics.yml            # user module fundamentals
├── 02-group-management.yml       # group module + supplementary groups
├── 03-authorized-keys.yml        # authorized_key module
├── 04-user-group-practical.yml   # Real-world team onboarding
└── README.md
```

---

## Playbooks

| # | Playbook | Concepts Covered |
|---|----------|------------------|
| 01 | user-basics.yml | `user` module, UID, shell, home, password, system user, remove |
| 02 | group-management.yml | `group` module, GID, system group, supplementary groups, `append` |
| 03 | authorized-keys.yml | `authorized_key`, inline key, file lookup, multiple keys, `exclusive`, `key_options` |
| 04 | user-group-practical.yml | End-to-end team provisioning: groups → users → SSH keys → deploy dir |

---

## Run the Playbooks

### Playbook 01: User Basics

```bash
# Run all user examples
ansible-playbook 01-user-basics.yml

# Verbose — see exactly what changed
ansible-playbook 01-user-basics.yml -v
```

**Covers:** create user, set UID/shell/home, system user, password hash, modify, remove

---

### Playbook 02: Group Management

```bash
# Run all group examples
ansible-playbook 02-group-management.yml

# Dry-run to preview changes
ansible-playbook 02-group-management.yml --check
```

**Covers:** create group, set GID, system group, add user to groups (append vs replace), remove group

---

### Playbook 03: Authorized Keys

```bash
# Run all authorized_key examples
ansible-playbook 03-authorized-keys.yml

# Run only the exclusive key example
ansible-playbook 03-authorized-keys.yml --tags exclusive
```

**Covers:** add key inline, add from file, multiple keys via loop, `key_options`, `exclusive`, remove key

---

### Playbook 04: Practical Team Onboarding

```bash
# Full team provisioning
ansible-playbook 04-user-group-practical.yml

# Dry-run first
ansible-playbook 04-user-group-practical.yml --check --diff

# Verbose output to see every step
ansible-playbook 04-user-group-practical.yml -v
```

**Covers:** end-to-end workflow — groups, users, group membership, SSH keys, CI service account, shared directory

---

## Module Quick Reference

### `user` Module

```yaml
- name: Create a user
  user:
    name: alice             # username (required)
    uid: 2001               # specific UID
    comment: "Alice Dev"    # GECOS field
    shell: /bin/bash        # login shell
    home: /home/alice       # home directory path
    create_home: true       # create home dir (default: true)
    system: false           # true = system account (UID < 1000)
    password: "{{ hash }}"  # pre-hashed password string
    update_password: on_create  # always | on_create
    groups:                 # supplementary groups
      - developers
      - devops
    append: true            # true = add to groups; false = replace
    state: present          # present | absent
    remove: true            # with absent: delete home dir
```

### `group` Module

```yaml
- name: Create a group
  group:
    name: developers    # group name (required)
    gid: 3001           # specific GID
    system: false       # true = system group (GID < 1000)
    state: present      # present | absent
```

### `authorized_key` Module

```yaml
- name: Add SSH key
  authorized_key:
    user: alice                          # username (required)
    key: "ssh-rsa AAAA... user@host"     # public key string (required)
    state: present                       # present | absent
    exclusive: false                     # true = remove all OTHER keys
    key_options: "no-port-forwarding"    # SSH authorized_keys options
    path: ~/.ssh/authorized_keys         # custom path (optional)
```

---

## Key Concepts

### `append: true` vs `append: false`

```yaml
# SAFE — adds to existing groups (keeps current memberships)
user:
  name: bob
  groups: [developers]
  append: true

# DESTRUCTIVE — replaces ALL supplementary groups
user:
  name: bob
  groups: [developers]
  append: false   # bob loses ALL other group memberships!
```

### Hashing Passwords

Ansible requires passwords to be pre-hashed. Use `password_hash` filter:

```yaml
vars:
  my_password: "MySecret123"

tasks:
  - name: Create user with hashed password
    user:
      name: alice
      password: "{{ my_password | password_hash('sha512') }}"
```

Or generate offline:

```bash
python3 -c "from passlib.hash import sha512_crypt; print(sha512_crypt.using(rounds=5000).hash('MySecret123'))"
```

### `exclusive: true` — Strict Key Control

```yaml
# Removes ANY key not listed here — useful for security enforcement
authorized_key:
  user: deploy
  key: "ssh-rsa AAAA... approved@security"
  exclusive: true
```

### SSH `key_options` — Restricting Keys

```yaml
authorized_key:
  user: backup
  key: "ssh-rsa AAAA... backup@remote"
  key_options: 'no-port-forwarding,no-X11-forwarding,command="/usr/bin/rsync --server"'
```

This generates an entry like:
```
no-port-forwarding,no-X11-forwarding,command="/usr/bin/rsync --server" ssh-rsa AAAA...
```

---

## System User vs Regular User

```
┌──────────────────┬──────────────────────┬─────────────────────────┐
│ Property         │ Regular User         │ System User             │
├──────────────────┼──────────────────────┼─────────────────────────┤
│ UID range        │ ≥ 1000               │ < 1000                  │
│ Home directory   │ /home/username       │ Usually none            │
│ Login shell      │ /bin/bash            │ /usr/sbin/nologin       │
│ Purpose          │ Human accounts       │ Services / daemons      │
│ Ansible option   │ system: false        │ system: true            │
└──────────────────┴──────────────────────┴─────────────────────────┘
```

---

## Key Takeaways

1. **`user`** — idempotent user management; use `state: absent` + `remove: true` to fully delete
2. **`group`** — idempotent group management; always set `gid` for consistency across hosts
3. **`append: true`** — always use this unless you specifically want to replace group memberships
4. **`authorized_key`** — manages individual keys; `exclusive: true` enforces strict key control
5. **`password_hash`** — never store plaintext passwords; use the filter or Ansible Vault
6. **`system: true`** — creates low-UID accounts for services with no interactive login
7. **`key_options`** — restrict what an SSH key can do (useful for CI/CD and backup accounts)
