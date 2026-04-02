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

# Chapter 11
# Ansible Vault

### Encrypt Secrets So They Never Live in Plain Text

---

## What You'll Learn

- What Ansible Vault is and why it matters
- Encrypting files with `ansible-vault encrypt`
- Viewing and editing encrypted files without decrypting to disk
- Encrypting individual strings with `ansible-vault encrypt_string`
- Running playbooks with `--ask-vault-pass`
- Using a vault password file for automation
- Multiple vault IDs for team-based secret separation
- Real-world: deploying an app with vault-encrypted credentials

---

## The Problem Vault Solves

```
  Without Vault:                     With Vault:
  ┌──────────────────────────────┐   ┌──────────────────────────────┐
  │ vars/secrets.yml             │   │ vars/secrets.yml             │
  │                              │   │                              │
  │ db_password: SuperSecret123! │   │ $ANSIBLE_VAULT;1.1;AES256    │
  │ api_key: sk-abc123xyz        │   │ 66386439653236336462626566   │
  │                              │   │ 65333762396230383361353134   │
  │ git commit → exposed! ❌     │   │                              │
  └──────────────────────────────┘   │ git commit → safe ✅         │
                                     └──────────────────────────────┘
```

> Vault encrypts with **AES-256** — the same standard used in banking

---

## Vault CLI Commands Overview

| Command | What it does |
|---------|-------------|
| `ansible-vault create` | Create a new encrypted file |
| `ansible-vault encrypt` | Encrypt an existing plain-text file |
| `ansible-vault decrypt` | Decrypt to plain text (use with caution) |
| `ansible-vault view` | View contents without writing plain text to disk |
| `ansible-vault edit` | Edit an encrypted file in-place |
| `ansible-vault rekey` | Change the vault password |
| `ansible-vault encrypt_string` | Encrypt a single string value |

---

## Creating and Encrypting Files

```bash
# Create a new encrypted file from scratch
ansible-vault create vars/secret_vars.yml
# Opens your editor — type secrets, save, done

# Encrypt an existing plain-text file
ansible-vault encrypt vars/secret_vars.yml

# Verify it is encrypted
head -1 vars/secret_vars.yml
# $ANSIBLE_VAULT;1.1;AES256
```

```yaml
# vars/secret_vars.yml — BEFORE encryption (plain text)
db_password: "SuperSecret123!"
api_key: "sk-abc123xyz"
app_secret_key: "django-insecure-replace-me"
```

> After `encrypt`, the file is replaced with AES-256 ciphertext in-place

---

## Viewing and Editing Encrypted Files

```bash
# View contents — decrypts to screen only, never writes plain text to disk
ansible-vault view vars/secret_vars.yml

# Edit in-place — decrypts to temp file, opens editor, re-encrypts on save
ansible-vault edit vars/secret_vars.yml

# Decrypt to plain text (careful — do not commit decrypted files)
ansible-vault decrypt vars/secret_vars.yml

# Change the vault password
ansible-vault rekey vars/secret_vars.yml
# Enter current password, then new password
```

> Always use `view` and `edit` — never `decrypt` unless absolutely necessary

---

## Using Encrypted Files in Playbooks

```yaml
- name: Deploy app with vault-encrypted secrets
  hosts: webservers
  become: true

  vars_files:
    - vars/app_config.yml   # plain — no vault needed
    - vars/secret_vars.yml  # vault-encrypted

  tasks:
    - name: Deploy .env file with decrypted secrets
      ansible.builtin.copy:
        dest: /opt/myapp/.env
        content: |
          DB_PASSWORD={{ db_password }}
          API_KEY={{ api_key }}
        mode: "0600"
```

```bash
# Run — Ansible prompts for the vault password
ansible-playbook site.yml --ask-vault-pass
```

> `vars_files` accepts both plain and encrypted files — Ansible decrypts at runtime

---

## What Happens at Runtime

```
  ansible-playbook site.yml --ask-vault-pass
         │
         ▼
  Enter vault password: ••••••••
         │
         ▼
  Ansible decrypts vars/secret_vars.yml in memory
         │
         ▼
  Variables available in all tasks
  (db_password, api_key, etc.)
         │
         ▼
  Plain text NEVER written to disk on control node
```

> Secrets exist in memory only during the playbook run

---

## ansible-vault encrypt_string

Encrypt a **single value** — embed it inline without a separate file.

```bash
# Generate an encrypted string
ansible-vault encrypt_string 'SuperSecret123!' --name 'db_password'
```

```yaml
# Output — copy this directly into your playbook or vars file
db_password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      66386439653236336462626566653337623962303833613531346234353861376630353765666362
      3437643831393831383961623934663566366164363430310a343937396261363463626235343339
      3863
```

> The `!vault` YAML tag tells Ansible: **decrypt this value at runtime**

---

## Using encrypt_string in a Playbook

```yaml
- name: Deploy with inline vault string
  hosts: webservers
  become: true

  vars:
    app_name: "myapp"
    # Generated: ansible-vault encrypt_string 'SuperSecret123!' --name 'db_password'
    db_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653236336462626566653337623962303833...

  tasks:
    - name: Show secret is available (never log the value itself)
      ansible.builtin.debug:
        msg: "db_password is set ({{ db_password | length }} chars)"
```

> Each variable is encrypted individually — the rest of the file stays readable

---

## Vault Password File

```bash
# Create and secure the password file
echo "MyVaultPassword123" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Pass it on the command line
ansible-playbook site.yml --vault-password-file ~/.vault_pass

# Or set it permanently in ansible.cfg
```

```ini
# ansible.cfg
[defaults]
vault_password_file = ~/.vault_pass
```

```bash
# Now just run — no flag needed
ansible-playbook site.yml
```

> Use password files in **CI/CD pipelines** so automation doesn't need human input

---

## .gitignore — Never Commit Secrets

```bash
# Add to .gitignore immediately
echo ".vault_pass"      >> .gitignore
echo "*.vault_pass"     >> .gitignore
echo "vars/secret_vars.yml" >> .gitignore  # only if keeping plain text locally
```

```
  What to commit:                What to NEVER commit:
  ✅ vars/secret_vars.yml        ❌ .vault_pass
     (encrypted version)         ❌ vars/secret_vars.yml (plain text)
  ✅ ansible.cfg                 ❌ any file with raw passwords
  ✅ playbooks
```

> The **encrypted** secrets file is safe to commit — the password file is not

---

## Multiple Vault IDs

```bash
# Create separate password files per team/environment
echo "DevPassword123"  > ~/.vault_pass_dev
echo "ProdPassword456" > ~/.vault_pass_prod
chmod 600 ~/.vault_pass_dev ~/.vault_pass_prod

# Encrypt files with a vault ID label
ansible-vault encrypt vars/dev_secrets.yml \
  --vault-id dev@~/.vault_pass_dev

ansible-vault encrypt vars/prod_secrets.yml \
  --vault-id prod@~/.vault_pass_prod

# Run playbook with both vault IDs
ansible-playbook site.yml \
  --vault-id dev@~/.vault_pass_dev \
  --vault-id prod@~/.vault_pass_prod
```

> Vault IDs let devs access dev secrets without ever seeing prod passwords

---

## Rotating the Vault Password

```bash
# Change the vault password without decrypting to disk
ansible-vault rekey vars/secret_vars.yml
# Enter current vault password:
# Enter new vault password:
# Confirm new vault password:
# Rekey successful

# Rekey multiple files at once
ansible-vault rekey vars/secret_vars.yml vars/prod_secrets.yml
```

> Rotate passwords regularly or immediately after a team member leaves

---

## Practical: Deploy App with Vault Secrets

```yaml
- name: "Deploy app with vault-encrypted secrets"
  hosts: webservers
  become: true

  vars_files:
    - vars/app_config.yml   # plain config
    - vars/secret_vars.yml  # vault-encrypted

  tasks:
    - name: Create application directory
      ansible.builtin.file:
        path: "/opt/{{ app_name }}"
        state: directory
        mode: "0750"

    - name: Deploy .env file with secrets
      ansible.builtin.copy:
        dest: "/opt/{{ app_name }}/.env"
        content: |
          DB_PASSWORD={{ db_password }}
          API_KEY={{ api_key }}
        mode: "0600"
```

---

## Practical: Assert File Permissions

```yaml
    - name: Verify .env exists and is locked down
      ansible.builtin.stat:
        path: "/opt/{{ app_name }}/.env"
      register: env_stat

    - name: Assert correct permissions
      ansible.builtin.assert:
        that:
          - env_stat.stat.exists
          - env_stat.stat.mode == "0600"
        success_msg: ".env deployed with correct permissions"
        fail_msg: ".env missing or has insecure permissions"
```

```bash
# Run
ansible-playbook 04-vault-practical.yml --ask-vault-pass
```

> Always assert `mode: "0600"` on files containing secrets

---

## Common Mistakes

### Mistake 1: Committing the plain-text secrets file

```bash
# ❌ Encrypting AFTER committing plain text — git history still has it
git add vars/secret_vars.yml   # plain text already staged
git commit                     # secret is now in git history forever

# ✅ Encrypt BEFORE the first commit
ansible-vault encrypt vars/secret_vars.yml
git add vars/secret_vars.yml   # now safe to commit
```

### Mistake 2: Using `debug` to print secret values

```yaml
# ❌ Leaks the secret into stdout and log files
- debug:
    msg: "Password is {{ db_password }}"

# ✅ Log length or existence only
- debug:
    msg: "Password is set ({{ db_password | length }} chars)"
```

---

## Common Mistakes (continued)

### Mistake 3: Decrypting a file instead of using view/edit

```bash
# ❌ Creates plain-text file on disk — easy to accidentally commit
ansible-vault decrypt vars/secret_vars.yml

# ✅ View without writing to disk
ansible-vault view vars/secret_vars.yml

# ✅ Edit in-place — re-encrypts automatically on save
ansible-vault edit vars/secret_vars.yml
```

### Mistake 4: Committing the vault password file

```bash
# ❌ Password file committed — vault is now useless
git add .vault_pass   # never do this

# ✅ Always add to .gitignore first
echo ".vault_pass" >> .gitignore
```

---

## Best Practices

| Practice | Why |
|----------|-----|
| Encrypt before first `git commit` | Git history is permanent — plain text leaks forever |
| Use `view` and `edit`, never `decrypt` | Prevents plain-text files sitting on disk |
| Never `debug` secret values | Secrets end up in stdout, logs, and CI output |
| Use `mode: "0600"` on secret files | Only root can read; assert it in playbooks |
| Store vault password in CI/CD secrets | Never hardcode in pipeline config files |
| Use vault IDs in large teams | Separate dev/prod access without sharing passwords |
| Rotate passwords with `rekey` | Limit blast radius when team members leave |

---

## Hands-on Exercises

```bash
cd chapter-11-ansible-vault

# Encrypt the secrets file
ansible-vault encrypt vars/secret_vars.yml

# View it without decrypting to disk
ansible-vault view vars/secret_vars.yml

# Run basics playbook
ansible-playbook 01-vault-basics.yml --ask-vault-pass

# Generate an inline encrypted string
ansible-vault encrypt_string 'MyApiKey123' --name 'api_key'

# Run with a password file
echo "MyVaultPassword" > ~/.vault_pass && chmod 600 ~/.vault_pass
ansible-playbook 03-vault-password-file.yml --vault-password-file ~/.vault_pass

# Full practical deployment
ansible-playbook 04-vault-practical.yml --ask-vault-pass
```

---

## Quick Reference

```bash
# File operations
ansible-vault create   vars/secrets.yml         # new encrypted file
ansible-vault encrypt  vars/secrets.yml         # encrypt existing file
ansible-vault view     vars/secrets.yml         # view without disk write
ansible-vault edit     vars/secrets.yml         # edit in-place
ansible-vault decrypt  vars/secrets.yml         # decrypt (use with care)
ansible-vault rekey    vars/secrets.yml         # rotate password

# Inline string
ansible-vault encrypt_string 'value' --name 'var_name'

# Run playbooks
ansible-playbook site.yml --ask-vault-pass
ansible-playbook site.yml --vault-password-file ~/.vault_pass
ansible-playbook site.yml --vault-id prod@~/.vault_pass_prod
```

---

## Key Takeaways

| Concept | Description |
|---------|-------------|
| `ansible-vault encrypt` | Encrypts entire file with AES-256 in-place |
| `ansible-vault encrypt_string` | Encrypts one value; embed with `!vault` tag |
| `vars_files` | Loads encrypted files same as plain — decrypts at runtime |
| `--ask-vault-pass` | Interactive password prompt for manual runs |
| `--vault-password-file` | Reads password from file; ideal for CI/CD |
| `ansible-vault rekey` | Rotates vault password without decrypting to disk |
| Vault IDs | Separate passwords per team or environment |

---

## Next Chapter

# Chapter 12
## File Management

- Copying files with `copy` and `synchronize`
- Managing file permissions with `file`
- Editing lines with `lineinfile` and `blockinfile`
- Fetching files from remote hosts with `fetch`

---

# Thank You!

### Questions?

**Key Takeaway:**
> "Encrypt first, commit second — git history is permanent and secrets in plain text are forever!"

**Resources:**
- [Ansible Vault docs](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
- [ansible-vault CLI reference](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html)
- [Vault best practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)

---
