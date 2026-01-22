# Chapter 01 - Hello Ansible

Welcome to your first Ansible chapter! This chapter introduces the basics of Ansible through simple examples.

## Prerequisites

- Ansible installed on your control node
- SSH access to managed nodes (lab servers)
- Update the `inventory` file with your server IPs

## Files in this Chapter

| File | Description |
|------|-------------|
| `ansible.cfg` | Ansible configuration file |
| `inventory` | List of managed hosts |
| `01-ping-playbook.yml` | Verify connectivity to hosts |
| `02-hello-world-playbook.yml` | Print Hello World message |
| `03-gather-facts-playbook.yml` | Collect system information |
| `04-dynamic-host-playbook.yml` | Pass server IP from command line |

## Getting Started

### Step 1: Update Inventory

Edit the `inventory` file and replace `<SERVER_X_IP>` with your actual server IPs:

```ini
[ansible_lab_servers]
ansible-lab-server-1 ansible_host=34.x.x.x
ansible-lab-server-2 ansible_host=34.x.x.x
ansible-lab-server-3 ansible_host=34.x.x.x
```

### Step 2: Test Connectivity with Ad-hoc Commands

```bash
# Ping all hosts
ansible all -m ping

# Run a shell command
ansible all -m shell -a "echo 'Hello from Ansible'"

# Check uptime
ansible all -m command -a "uptime"
```

### Step 3: Run Playbooks

```bash
# Run ping playbook
ansible-playbook 01-ping-playbook.yml

# Run hello world playbook
ansible-playbook 02-hello-world-playbook.yml

# Run gather facts playbook
ansible-playbook 03-gather-facts-playbook.yml

# Run dynamic host playbook (pass IP from command line)
ansible-playbook 04-dynamic-host-playbook.yml -i "34.2.54.150," -e "target_host=34.2.54.150"
```

## Key Concepts Covered

1. **Inventory** - Defining managed hosts
2. **Ad-hoc Commands** - Running quick one-liner commands
3. **Playbooks** - YAML files containing automation tasks
4. **Modules** - `ping`, `debug`, `shell`, `command`
5. **Facts** - System information gathered by Ansible
6. **Extra Variables** - Passing variables from command line using `-e`

## Expected Output

### Ping Playbook
```
PLAY [Ping all hosts] **********************************************************

TASK [Ping the server] *********************************************************
ok: [ansible-lab-server-1]
ok: [ansible-lab-server-2]
ok: [ansible-lab-server-3]

PLAY RECAP *********************************************************************
ansible-lab-server-1       : ok=1    changed=0    unreachable=0    failed=0
ansible-lab-server-2       : ok=1    changed=0    unreachable=0    failed=0
ansible-lab-server-3       : ok=1    changed=0    unreachable=0    failed=0
```

### Hello World Playbook
```
TASK [Print Hello World message] ***********************************************
ok: [ansible-lab-server-1] => {
    "msg": "Hello World from Ansible!"
}
```
