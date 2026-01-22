# Chapter 02 - Inventory Deep Dive

Master Ansible inventory management - from basic host lists to complex group hierarchies.

## What You'll Learn

- Static inventory in INI and YAML formats
- Organizing hosts into groups
- Nested groups using `:children`
- Host and group variables
- Host patterns for targeting specific hosts
- Using `--limit` for runtime filtering

---

## Quick Start

### Step 1: Navigate to this chapter

```bash
cd chapter-02-inventory-deep-dive
```

### Step 2: Update Inventory with Your Server IPs

Edit `inventory/hosts.ini` and replace `<SERVER_X_IP>` with your actual IPs:

```bash
vim inventory/hosts.ini
```

Example:
```ini
[webservers]
ansible-lab-server-1 ansible_host=34.2.54.150
ansible-lab-server-2 ansible_host=34.2.54.151

[dbservers]
ansible-lab-server-3 ansible_host=34.2.54.152
```

### Step 3: Verify Your Inventory

```bash
# List all hosts
ansible all --list-hosts

# List hosts in webservers group
ansible webservers --list-hosts

# Show inventory in graph format
ansible-inventory --graph

# Show inventory with all variables
ansible-inventory --list
```

---

## Run the Playbooks

### Playbook 01: Target All Hosts

**Concept:** Run tasks on all hosts in inventory

```bash
ansible-playbook 01-target-all-hosts.yml
```

---

### Playbook 02: Target Specific Group

**Concept:** Run tasks only on webservers or dbservers group

```bash
ansible-playbook 02-target-specific-group.yml
```

---

### Playbook 03: Target Multiple Groups (Union)

**Concept:** Run tasks on hosts in webservers OR dbservers (Union)

```bash
ansible-playbook 03-target-multiple-groups.yml
```

---

### Playbook 04: Host Patterns - Intersection

**Concept:** Run tasks on hosts that are in BOTH webservers AND loadbalancers

```bash
ansible-playbook 04-host-patterns-intersection.yml
```

---

### Playbook 05: Host Patterns - Exclusion

**Concept:** Run tasks on all hosts EXCEPT dbservers

```bash
ansible-playbook 05-host-patterns-exclusion.yml
```

---

### Playbook 06: Host Patterns - Wildcards

**Concept:** Target hosts using wildcard patterns like `ansible-*`

```bash
ansible-playbook 06-host-patterns-wildcards.yml
```

---

### Playbook 07: Host Patterns - Regex

**Concept:** Target hosts using regular expressions

```bash
ansible-playbook 07-host-patterns-regex.yml
```

---

### Playbook 08: Display Inventory Information

**Concept:** Display inventory hostname, groups, and all hosts

```bash
ansible-playbook 08-display-inventory-info.yml
```

---

### Playbook 09: Display Group Variables

**Concept:** Display variables defined in inventory (group_vars, host_vars)

```bash
ansible-playbook 09-display-group-variables.yml
```

---

### Playbook 10: Using --limit Option

**Concept:** Limit playbook execution to specific hosts at runtime

```bash
# Run on all hosts
ansible-playbook 10-limit-and-subset.yml

# Run only on webservers group
ansible-playbook 10-limit-and-subset.yml --limit webservers

# Run only on a specific host
ansible-playbook 10-limit-and-subset.yml --limit ansible-lab-server-1

# Run on webservers except loadbalancers
ansible-playbook 10-limit-and-subset.yml --limit 'webservers:!loadbalancers'
```

---

## Inventory Files Included

| File | Description |
|------|-------------|
| `inventory/hosts.ini` | Main inventory file (default) |
| `inventory/01-basic-inventory.ini` | Simple host list |
| `inventory/02-groups-inventory.ini` | Hosts organized in groups |
| `inventory/03-nested-groups-inventory.ini` | Parent/child group hierarchy |
| `inventory/04-host-variables-inventory.ini` | Per-host variables |
| `inventory/05-ranges-inventory.ini` | Using ranges for multiple hosts |
| `inventory/06-yaml-inventory.yml` | YAML format inventory |

### Using Different Inventory Files

```bash
# Use basic inventory
ansible-playbook 01-target-all-hosts.yml -i inventory/01-basic-inventory.ini

# Use groups inventory
ansible-playbook 02-target-specific-group.yml -i inventory/02-groups-inventory.ini

# Use nested groups inventory
ansible-playbook 03-target-multiple-groups.yml -i inventory/03-nested-groups-inventory.ini

# Use YAML inventory
ansible-playbook 01-target-all-hosts.yml -i inventory/06-yaml-inventory.yml
```

---

## Host Pattern Quick Reference

| Pattern | Meaning | Example |
|---------|---------|---------|
| `all` | All hosts | `hosts: all` |
| `*` | All hosts (wildcard) | `hosts: *` |
| `groupname` | Single group | `hosts: webservers` |
| `group1,group2` | Union (OR) | `hosts: webservers,dbservers` |
| `group1:&group2` | Intersection (AND) | `hosts: webservers:&loadbalancers` |
| `group1:!group2` | Exclusion (NOT) | `hosts: all:!dbservers` |
| `*.example.com` | Wildcard match | `hosts: *.example.com` |
| `~regex` | Regex match | `hosts: ~web-[0-9]+` |

---

## Ad-hoc Commands

```bash
# Ping all hosts
ansible all -m ping

# Ping only webservers
ansible webservers -m ping

# Ping hosts in both webservers AND loadbalancers
ansible 'webservers:&loadbalancers' -m ping

# Ping all hosts EXCEPT dbservers
ansible 'all:!dbservers' -m ping

# Run shell command on webservers
ansible webservers -m shell -a "uptime"

# Check disk space on all hosts
ansible all -m command -a "df -h"
```

---

## Key Takeaways

1. **Groups** - Organize hosts logically (webservers, dbservers, production)
2. **Nested groups** - Create hierarchies using `:children`
3. **Variables** - Set per-host or per-group in inventory
4. **Host patterns** - Precise control over which hosts to target
5. **YAML format** - More readable for complex inventories
6. **`--limit`** - Filter hosts at runtime without changing playbooks
