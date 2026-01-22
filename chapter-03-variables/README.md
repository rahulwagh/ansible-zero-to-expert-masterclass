# Chapter 03 - Variables

Master Ansible variables - from inline definitions to complex precedence rules.

## What You'll Learn

- Defining variables inline with `vars`
- Loading variables from files with `vars_files`
- Using `group_vars/` for group-specific variables
- Using `host_vars/` for host-specific variables
- Understanding variable precedence
- Using extra vars (`-e`) for runtime overrides
- Registering task output as variables
- Working with Ansible facts
- Magic variables (special variables)
- Variable scopes

---

## Quick Start

### Step 1: Navigate to this chapter

```bash
cd chapter-03-variables
```

### Step 2: Update Inventory with Your Server IPs

Edit `inventory/hosts.ini` and replace `<SERVER_X_IP>` with your actual IPs:

```bash
vim inventory/hosts.ini
```

### Step 3: Verify Your Setup

```bash
# Test connectivity
ansible all -m ping

# View inventory with variables
ansible-inventory --list
```

---

## Directory Structure

```
chapter-03-variables/
├── ansible.cfg
├── inventory/
│   └── hosts.ini
├── group_vars/
│   ├── all.yml          # Variables for ALL hosts
│   ├── webservers.yml   # Variables for webservers group
│   ├── dbservers.yml    # Variables for dbservers group
│   └── production.yml   # Variables for production group
├── host_vars/
│   ├── ansible-lab-server-1.yml
│   ├── ansible-lab-server-2.yml
│   └── ansible-lab-server-3.yml
├── vars/
│   ├── common.yml       # Common variables (loaded via vars_files)
│   ├── web_config.yml   # Web server config variables
│   └── db_config.yml    # Database config variables
└── playbooks (01-10)
```

---

## Run the Playbooks

### Playbook 01: Variables Inline (vars)

**Concept:** Define variables directly in the playbook

```bash
ansible-playbook 01-vars-inline.yml
```

**Key Points:**
- Simple strings, numbers, booleans
- Lists and dictionaries
- Multi-line strings
- Variable referencing other variables

---

### Playbook 02: Variables from Files (vars_files)

**Concept:** Load variables from external YAML files

```bash
ansible-playbook 02-vars-files.yml
```

**Key Points:**
- Keeps playbooks clean and organized
- Reuse variable files across playbooks
- Separate configuration from logic

---

### Playbook 03: Group Variables (group_vars/)

**Concept:** Automatic variable loading based on group membership

```bash
ansible-playbook 03-group-vars.yml
```

**Key Points:**
- `group_vars/all.yml` applies to all hosts
- `group_vars/<groupname>.yml` applies to specific groups
- Variables are automatically loaded

---

### Playbook 04: Host Variables (host_vars/)

**Concept:** Per-host variable files that override group_vars

```bash
ansible-playbook 04-host-vars.yml
```

**Key Points:**
- Higher precedence than group_vars
- Use for host-specific overrides
- Named after the inventory hostname

---

### Playbook 05: Variable Precedence

**Concept:** Understanding how variables override each other

```bash
# See which level the variable comes from
ansible-playbook 05-variable-precedence.yml

# Override with command line (highest precedence)
ansible-playbook 05-variable-precedence.yml -e "precedence_test='from command line'"
```

**Precedence Order (lowest to highest):**
1. role defaults
2. inventory group_vars/all
3. inventory group_vars/*
4. inventory host_vars/*
5. play vars
6. play vars_files
7. task vars
8. set_facts
9. **extra vars (-e)** ← Highest

---

### Playbook 06: Extra Variables (-e)

**Concept:** Override any variable from the command line

```bash
# Default values
ansible-playbook 06-extra-vars.yml

# Override single variable
ansible-playbook 06-extra-vars.yml -e "target_env=staging"

# Override multiple variables
ansible-playbook 06-extra-vars.yml -e "target_env=production debug=true"

# JSON format
ansible-playbook 06-extra-vars.yml -e '{"target_env": "dev", "version": "2.0"}'

# Load from file
ansible-playbook 06-extra-vars.yml -e "@vars/common.yml"
```

---

### Playbook 07: Register Variables

**Concept:** Capture task output into variables

```bash
ansible-playbook 07-register-variables.yml
```

**Key Points:**
- `register: result` captures output
- Access with `result.stdout`, `result.rc`, etc.
- Use in conditionals with `when`

---

### Playbook 08: Ansible Facts

**Concept:** System information gathered from managed hosts

```bash
ansible-playbook 08-facts-as-variables.yml
```

**Key Points:**
- Automatically gathered (or use `gather_facts: false`)
- Access with `ansible_*` variables
- Filter facts for faster gathering
- Create custom facts in `/etc/ansible/facts.d/`

**Useful Facts:**
- `ansible_os_family`: Debian, RedHat, etc.
- `ansible_distribution`: Ubuntu, CentOS, etc.
- `ansible_hostname`: Short hostname
- `ansible_default_ipv4.address`: Primary IP
- `ansible_memtotal_mb`: Total RAM

---

### Playbook 09: Magic Variables

**Concept:** Special variables automatically set by Ansible

```bash
ansible-playbook 09-magic-variables.yml
```

**Key Magic Variables:**
| Variable | Description |
|----------|-------------|
| `inventory_hostname` | Current host name |
| `group_names` | Groups the host belongs to |
| `groups` | All groups and their members |
| `hostvars` | Variables for all hosts |
| `ansible_play_hosts` | Hosts in current play |
| `playbook_dir` | Playbook directory path |
| `ansible_check_mode` | True if --check mode |

---

### Playbook 10: Variable Scopes

**Concept:** Understanding where variables exist and persist

```bash
ansible-playbook 10-variable-scopes.yml
```

**Scope Types:**
| Scope | Set By | Lifetime |
|-------|--------|----------|
| Global | -e, config, env | Entire run |
| Play | vars, vars_files | Current play |
| Host | set_fact, host_vars | Entire run (per host) |
| Block | vars in block | Block tasks only |
| Task | vars on task | Single task |

---

## Variable Precedence (Complete List)

From lowest to highest precedence:

```
1.  command line values (e.g., -u user)
2.  role defaults (role/defaults/main.yml)
3.  inventory file or script group vars
4.  inventory group_vars/all
5.  playbook group_vars/all
6.  inventory group_vars/*
7.  playbook group_vars/*
8.  inventory file or script host vars
9.  inventory host_vars/*
10. playbook host_vars/*
11. host facts / cached set_facts
12. play vars
13. play vars_prompt
14. play vars_files
15. role vars (role/vars/main.yml)
16. block vars
17. task vars
18. include_vars
19. set_facts / registered vars
20. role params
21. include params
22. extra vars (-e) ← ALWAYS WINS
```

---

## Ad-hoc Commands with Variables

```bash
# Pass extra vars
ansible all -m debug -a "msg={{ my_var }}" -e "my_var=hello"

# Show all variables for a host
ansible ansible-lab-server-1 -m debug -a "var=hostvars[inventory_hostname]"

# Show specific fact
ansible all -m setup -a "filter=ansible_distribution"

# Show group membership
ansible all -m debug -a "var=group_names"
```

---

## Best Practices

1. **Use group_vars/all.yml** for common defaults
2. **Use group_vars/<group>.yml** for role-specific settings
3. **Use host_vars/** only for true host-specific overrides
4. **Use vars_files** for environment-specific configs
5. **Use -e** for runtime overrides and CI/CD
6. **Never store secrets in plain text** - use Ansible Vault (next chapter!)
7. **Keep variable names descriptive** and consistent
8. **Document complex variables** with comments

---

## Key Takeaways

1. **vars** - Define variables directly in playbooks
2. **vars_files** - Load variables from external files
3. **group_vars/** - Automatic variables by group membership
4. **host_vars/** - Per-host variable overrides
5. **-e (extra vars)** - Highest precedence, command-line overrides
6. **register** - Capture task output into variables
7. **facts** - System info gathered from hosts
8. **magic variables** - Special Ansible-provided variables
9. **Precedence matters** - Know which level wins
10. **Scope matters** - Know where variables persist
