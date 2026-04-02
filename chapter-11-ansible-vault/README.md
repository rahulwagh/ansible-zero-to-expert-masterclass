# Chapter 11 - Ansible Vault

Protect sensitive data — passwords, API keys, and certificates — by encrypting them with Ansible Vault so secrets never live in plain text in your repository.

## What You'll Learn

- What Ansible Vault is and why it matters
- Encrypting and decrypting files with `ansible-vault`
- Viewing and editing encrypted files without decrypting to disk
- Encrypting individual strings with `ansible-vault encrypt_string`
- Using encrypted vars in playbooks with `--ask-vault-pass`
- Using a vault password file to avoid typing the password every run
- Multiple vault IDs for team-based secret separation
- Real-world: deploying an app with vault-encrypted credentials

---

## Quick Start

```bash
cd chapter-11-ansible-vault

# Encrypt the secrets file
ansible-vault encrypt vars/secret_vars.yml

# Run the basics playbook
ansible-playbook 01-vault-basics.yml --ask-vault-pass

# Generate an inline encrypted string
ansible-vault encrypt_string 'SuperSecret123!' --name 'db_password'

# Run with a password file
echo "MyVaultPassword" > ~/.vault_pass && chmod 600 ~/.vault_pass
ansible-playbook 03-vault-password-file.yml --vault-password-file ~/.vault_pass
```

---

## Directory Structure

```
chapter-11-ansible-vault/
├── ansible.cfg
├── inventory/
│   └── hosts.ini
├── vars/
│   ├── secret_vars.yml         # encrypt this before committing
│   └── app_config.yml          # plain (non-sensitive) config
├── slides/
│   ├── chapter-11-presentation.md
│   └── chapter-11-presentation.pptx
├── 01-vault-basics.yml         # encrypt file + use in playbook
├── 02-encrypt-string.yml       # inline encrypt_string values
├── 03-vault-password-file.yml  # password file + vault IDs
├── 04-vault-practical.yml      # real-world app deployment
└── README.md
```

---

## Playbooks

| # | Playbook | Concepts Covered |
|---|----------|------------------|
| 01 | vault-basics.yml | `ansible-vault encrypt`, `vars_files`, `--ask-vault-pass`, mixing plain + encrypted vars |
| 02 | encrypt-string.yml | `ansible-vault encrypt_string`, `!vault` inline blocks |
| 03 | vault-password-file.yml | `--vault-password-file`, `vault_password_file` in ansible.cfg, vault IDs |
| 04 | vault-practical.yml | Full deployment with encrypted credentials, `assert` for permission checks |

---

## Run the Playbooks

### Setup — Encrypt the Secrets File

```bash
# Encrypt vars/secret_vars.yml with a password you choose
ansible-vault encrypt vars/secret_vars.yml

# Verify it is encrypted (should show $ANSIBLE_VAULT header)
head -1 vars/secret_vars.yml

# View contents without decrypting to disk
ansible-vault view vars/secret_vars.yml
```

---

### Playbook 01: Vault Basics

```bash
# Run with interactive password prompt
ansible-playbook 01-vault-basics.yml --ask-vault-pass

# Verbose — see every task
ansible-playbook 01-vault-basics.yml --ask-vault-pass -v
```

**Covers:** encrypting a file, loading encrypted `vars_files`, mixing plain and vault vars

---

### Playbook 02: encrypt_string

```bash
# Generate an encrypted string (copy the output into the playbook)
ansible-vault encrypt_string 'SuperSecret123!' --name 'db_password'
ansible-vault encrypt_string 'sk-abc123xyz' --name 'api_key'

# Run
ansible-playbook 02-encrypt-string.yml --ask-vault-pass
```

**Covers:** `!vault` inline blocks, per-variable encryption without encrypting the whole file

---

### Playbook 03: Vault Password File

```bash
# Create the password file (keep this out of version control)
echo "MyVaultPassword123" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Re-encrypt the secrets file with the same password
ansible-vault rekey vars/secret_vars.yml

# Run without typing the password
ansible-playbook 03-vault-password-file.yml --vault-password-file ~/.vault_pass

# Or set vault_password_file in ansible.cfg, then just:
ansible-playbook 03-vault-password-file.yml
```

**Covers:** password files, `ansible.cfg` vault settings, multiple vault IDs

---

### Playbook 04: Practical Deployment

```bash
# Step 1: encrypt secrets
ansible-vault encrypt vars/secret_vars.yml

# Step 2: dry-run
ansible-playbook 04-vault-practical.yml --ask-vault-pass --check

# Step 3: deploy
ansible-playbook 04-vault-practical.yml --ask-vault-pass

# Step 4: verify on the server
ssh ansible@<server-ip> "stat /opt/myapp/.env"
```

**Covers:** full deployment with vault, file permission assertions, secret rotation with `rekey`

---

## Vault CLI Quick Reference

### File Operations

```bash
# Create a new encrypted file
ansible-vault create vars/secret_vars.yml

# Encrypt an existing plain-text file
ansible-vault encrypt vars/secret_vars.yml

# Decrypt to plain text (use with caution)
ansible-vault decrypt vars/secret_vars.yml

# View encrypted file contents
ansible-vault view vars/secret_vars.yml

# Edit encrypted file in-place
ansible-vault edit vars/secret_vars.yml

# Change the vault password
ansible-vault rekey vars/secret_vars.yml
```

### encrypt_string

```bash
# Encrypt a single string value
ansible-vault encrypt_string 'MySecret' --name 'var_name'

# Encrypt and read from stdin (avoids password in shell history)
ansible-vault encrypt_string --name 'db_password'
<enter secret, then Ctrl+D>
```

### Running Playbooks

```bash
# Prompt for vault password
ansible-playbook site.yml --ask-vault-pass

# Use a password file
ansible-playbook site.yml --vault-password-file ~/.vault_pass

# Use multiple vault IDs
ansible-playbook site.yml \
  --vault-id dev@~/.vault_pass_dev \
  --vault-id prod@~/.vault_pass_prod
```

---

## Key Concepts

### Encrypted File Format

```
$ANSIBLE_VAULT;1.1;AES256
66386439653236336462626566653337623962303833613531346234353861376630353765666362
3437643831393831383961623934663566366164363430310a343937396261363463626235343339
...
```

The first line is the vault header. Everything after is AES-256 encrypted content.

### encrypt_string Format

```yaml
# Generated by: ansible-vault encrypt_string 'SuperSecret123!' --name 'db_password'
db_password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      66386439653236336462626566653337623962303833613531...
```

The `!vault` YAML tag tells Ansible to decrypt this value at runtime.

### Vault Password File

```bash
# Create and secure the file
echo "MyVaultPassword" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Set in ansible.cfg to avoid passing it on every command
[defaults]
vault_password_file = ~/.vault_pass
```

**Never commit the password file.** Add to `.gitignore`:
```bash
echo ".vault_pass" >> .gitignore
echo "*.vault_pass" >> .gitignore
```

### Multiple Vault IDs

```bash
# Encrypt different files with different passwords
ansible-vault encrypt vars/dev_secrets.yml  --vault-id dev@~/.vault_pass_dev
ansible-vault encrypt vars/prod_secrets.yml --vault-id prod@~/.vault_pass_prod

# Run with both passwords
ansible-playbook site.yml \
  --vault-id dev@~/.vault_pass_dev \
  --vault-id prod@~/.vault_pass_prod
```

---

## Key Takeaways

1. **`ansible-vault encrypt`** — encrypts an entire file with AES-256
2. **`ansible-vault encrypt_string`** — encrypts a single value for inline use with `!vault`
3. **`vars_files`** — loads encrypted files the same way as plain files; Ansible decrypts at runtime
4. **`--ask-vault-pass`** — prompts for the password interactively
5. **`--vault-password-file`** — reads the password from a file; use in CI/CD pipelines
6. **`vault_password_file`** in `ansible.cfg` — sets the default password file for all runs
7. **`ansible-vault rekey`** — rotate the vault password without decrypting to disk
8. **Never commit** the vault password file or decrypted secrets to version control
