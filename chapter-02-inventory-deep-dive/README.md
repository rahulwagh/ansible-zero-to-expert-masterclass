# Chapter 02 - Inventory Deep Dive

Master Ansible inventory management - from basic host lists to complex group hierarchies.

## What You'll Learn

- Static inventory in INI and YAML formats
- Organizing hosts into groups
- Nested groups using `:children`
- Host and group variables
- Host patterns for targeting specific hosts
- Using `--limit` for runtime filtering

## Files in this Chapter

### Inventory Examples

| File | Description |
|------|-------------|
| `inventory/hosts.ini` | Main inventory file (default) |
| `inventory/01-basic-inventory.ini` | Simple host list |
| `inventory/02-groups-inventory.ini` | Hosts organized in groups |
| `inventory/03-nested-groups-inventory.ini` | Parent/child group hierarchy |
| `inventory/04-host-variables-inventory.ini` | Per-host variables |
| `inventory/05-ranges-inventory.ini` | Using ranges for multiple hosts |
| `inventory/06-yaml-inventory.yml` | YAML format inventory |

### Playbooks

| Playbook | Concept | Command |
|----------|---------|---------|
| `01-target-all-hosts.yml` | Target all hosts | `ansible-playbook 01-target-all-hosts.yml` |
| `02-target-specific-group.yml` | Target a group | `ansible-playbook 02-target-specific-group.yml` |
| `03-target-multiple-groups.yml` | Union of groups | `ansible-playbook 03-target-multiple-groups.yml` |
| `04-host-patterns-intersection.yml` | Intersection (&) | `ansible-playbook 04-host-patterns-intersection.yml` |
| `05-host-patterns-exclusion.yml` | Exclusion (!) | `ansible-playbook 05-host-patterns-exclusion.yml` |
| `06-host-patterns-wildcards.yml` | Wildcards (*) | `ansible-playbook 06-host-patterns-wildcards.yml` |
| `07-host-patterns-regex.yml` | Regex (~) | `ansible-playbook 07-host-patterns-regex.yml` |
| `08-display-inventory-info.yml` | Inventory variables | `ansible-playbook 08-display-inventory-info.yml` |
| `09-display-group-variables.yml` | Group/host vars | `ansible-playbook 09-display-group-variables.yml` |
| `10-limit-and-subset.yml` | --limit option | `ansible-playbook 10-limit-and-subset.yml --limit webservers` |

## Getting Started

### Step 1: Update Inventory

Edit `inventory/hosts.ini` and replace `<SERVER_X_IP>` with your actual IPs:

```ini
[webservers]
ansible-lab-server-1 ansible_host=34.x.x.x
ansible-lab-server-2 ansible_host=34.x.x.x

[dbservers]
ansible-lab-server-3 ansible_host=34.x.x.x
```

### Step 2: Verify Inventory

```bash
# List all hosts
ansible all --list-hosts

# List hosts in a specific group
ansible webservers --list-hosts

# Show inventory in graph format
ansible-inventory --graph

# Show inventory with all variables
ansible-inventory --list
```

## Host Pattern Reference

| Pattern | Meaning | Example |
|---------|---------|---------|
| `all` | All hosts | `hosts: all` |
| `*` | All hosts (wildcard) | `hosts: *` |
| `groupname` | Single group | `hosts: webservers` |
| `group1,group2` | Union (OR) | `hosts: webservers,dbservers` |
| `group1:group2` | Union (OR) | `hosts: webservers:dbservers` |
| `group1:&group2` | Intersection (AND) | `hosts: webservers:&loadbalancers` |
| `group1:!group2` | Exclusion (NOT) | `hosts: all:!dbservers` |
| `*.example.com` | Wildcard match | `hosts: *.example.com` |
| `~regex` | Regex match | `hosts: ~web-[0-9]+` |

## Inventory Formats

### INI Format (Default)

```ini
[webservers]
web1.example.com
web2.example.com ansible_host=192.168.1.2

[webservers:vars]
http_port=80

[all:vars]
ansible_user=ansible
```

### YAML Format

```yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
          ansible_host: 192.168.1.2
      vars:
        http_port: 80
  vars:
    ansible_user: ansible
```

## Special Groups

Ansible automatically creates two groups:

| Group | Contains |
|-------|----------|
| `all` | Every host in the inventory |
| `ungrouped` | Hosts not in any group (except `all`) |

## Command Line Examples

```bash
# Use a different inventory file
ansible-playbook playbook.yml -i inventory/02-groups-inventory.ini

# Limit to specific hosts
ansible-playbook playbook.yml --limit webservers
ansible-playbook playbook.yml --limit 'webservers:!loadbalancers'
ansible-playbook playbook.yml --limit ansible-lab-server-1

# Ad-hoc commands with patterns
ansible webservers -m ping
ansible 'webservers:&loadbalancers' -m ping
ansible 'all:!dbservers' -m shell -a "uptime"
```

## Key Takeaways

1. **Groups** organize hosts logically (webservers, dbservers, production, etc.)
2. **Nested groups** create hierarchies using `:children`
3. **Variables** can be set per-host or per-group
4. **Host patterns** give precise control over which hosts to target
5. **YAML format** is more readable for complex inventories
6. **`--limit`** filters hosts at runtime without changing playbooks
