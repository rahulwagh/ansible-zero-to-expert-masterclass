# Ansible Installation on Windows using WSL (Ubuntu)

Run Ansible on Windows using Windows Subsystem for Linux (WSL) with Ubuntu.

---

## Prerequisites

- Windows 10 version 2004+ (Build 19041+) or Windows 11
- Administrator access

---

## Part 1: Install WSL2 and Ubuntu

Open **PowerShell as Administrator** and run the following commands:

### Step 1: Enable WSL

```powershell
wsl --install
```

### Step 2: Update WSL

```powershell
wsl --update
```

### Step 3: Set WSL2 as Default

```powershell
wsl --set-default-version 2
```

### Step 4: List Available Distributions

```powershell
wsl --list --online
```

### Step 5: Install Ubuntu 22.04

```powershell
wsl --install -d Ubuntu-22.04
```

### Step 6: Restart Computer

Restart your computer and open Ubuntu from Start Menu.

### Step 7: Create Username and Password

When Ubuntu opens, create your username and password.

### Step 8: Verify Installation

```powershell
wsl --list --verbose
```

---

## Part 2: Install Ansible in Ubuntu

Open **Ubuntu** from Start Menu and run the following commands:

### Step 9: Update Packages

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 10: Install Python and pip

```bash
sudo apt install python3 python3-pip -y
```

### Step 11: Install Ansible

```bash
pip3 install ansible
```

### Step 12: Add to PATH

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

### Step 13: Verify Ansible

```bash
ansible --version
```

---

## Part 3: Test Ansible

### Step 14: Create Test Inventory

```bash
echo "localhost ansible_connection=local" > inventory
```

### Step 15: Run Ping Test

```bash
ansible all -i inventory -m ping
```

---

## Part 4: SSH Key Setup

### Step 16: Generate SSH Key

```bash
ssh-keygen -t rsa -b 4096
```

### Step 17: Copy Key to Remote Server

```bash
ssh-copy-id username@server-ip
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Open Ubuntu | `wsl` |
| List distributions | `wsl --list --online` |
| Shutdown WSL | `wsl --shutdown` |
| Check Ansible version | `ansible --version` |
| Upgrade Ansible | `pip3 install --upgrade ansible` |

---

## Troubleshooting

### ansible command not found

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

### Permission denied on SSH

```bash
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_rsa
```
