<p align="center">
  <img src="https://www.ansible.com/hubfs/Images/Red-Hat-Ansible_OG_1200x630.png" alt="Ansible Logo" width="400"/>
</p>

<h1 align="center">Ansible Zero to Expert Masterclass</h1>

<p align="center">
  <strong>From Your First Playbook to Production-Ready Automation</strong>
</p>

<p align="center">
  <a href="#-course-overview">Overview</a> •
  <a href="#-chapters">Chapters</a> •
  <a href="#-prerequisites">Prerequisites</a> •
  <a href="#-lab-setup">Lab Setup</a> •
  <a href="#-quick-start">Quick Start</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Ansible-2.15+-red?style=for-the-badge&logo=ansible" alt="Ansible"/>
  <img src="https://img.shields.io/badge/Level-Beginner%20to%20Expert-blue?style=for-the-badge" alt="Level"/>
  <img src="https://img.shields.io/badge/Chapters-24-green?style=for-the-badge" alt="Chapters"/>
</p>

---

## 📖 Course Overview

Welcome to the **Ansible Zero to Expert Masterclass**! This comprehensive course takes you from writing your first "Hello World" playbook to building production-ready automation solutions.

### What You'll Learn

```
✅ Ansible fundamentals and core concepts
✅ Writing efficient and reusable playbooks
✅ Managing infrastructure at scale
✅ Security best practices with Ansible Vault
✅ Building custom roles and modules
✅ Real-world automation projects
```

### Who Is This Course For?

| Audience | Description |
|----------|-------------|
| 🌱 **Beginners** | No prior Ansible experience required |
| 💼 **DevOps Engineers** | Enhance your automation skills |
| 🖥️ **System Administrators** | Automate repetitive tasks |
| ☁️ **Cloud Engineers** | Manage cloud infrastructure with code |

---

## 📚 Chapters

### 🟢 Foundation (Chapters 1-5)

| # | Chapter | Description | Status |
|---|---------|-------------|--------|
| 01 | [Hello Ansible](./chapter-01-hello-ansible/) | Your first playbook, ad-hoc commands, ping, debug | ✅ Ready |
| 02 | Inventory Deep Dive | Static inventory, groups, host patterns | 📝 Coming Soon |
| 03 | Variables | vars, vars_files, host_vars, group_vars | 📝 Coming Soon |
| 04 | Facts & Magic Variables | gather_facts, ansible_facts, set_fact | 📝 Coming Soon |
| 05 | Conditionals | when, failed_when, changed_when | 📝 Coming Soon |

### 🟡 Intermediate (Chapters 6-12)

| # | Chapter | Description | Status |
|---|---------|-------------|--------|
| 06 | Loops | loop, with_items, with_dict, loop_control | 📝 Coming Soon |
| 07 | Handlers | handlers, notify, listen, flush_handlers | 📝 Coming Soon |
| 08 | Tags | tags, always, never, --tags, --skip-tags | 📝 Coming Soon |
| 09 | Register & Debug | register, debug, assert, fail | 📝 Coming Soon |
| 10 | Templates | Jinja2 templates, filters, template module | 📝 Coming Soon |
| 11 | File Management | copy, file, lineinfile, blockinfile | 📝 Coming Soon |
| 12 | Package Management | apt, yum, package, pip | 📝 Coming Soon |

### 🟠 Advanced (Chapters 13-18)

| # | Chapter | Description | Status |
|---|---------|-------------|--------|
| 13 | Service Management | service, systemd, restarted, enabled | 📝 Coming Soon |
| 14 | User & Group Management | user, group, authorized_key | 📝 Coming Soon |
| 15 | Blocks & Error Handling | block, rescue, always, ignore_errors | 📝 Coming Soon |
| 16 | Roles | Role structure, defaults, tasks, handlers | 📝 Coming Soon |
| 17 | Ansible Galaxy | Install roles, collections, requirements.yml | 📝 Coming Soon |
| 18 | Vault | Encryption, vault password, encrypt_string | 📝 Coming Soon |

### 🔴 Expert (Chapters 19-24)

| # | Chapter | Description | Status |
|---|---------|-------------|--------|
| 19 | Dynamic Inventory | Scripts, plugins, cloud providers | 📝 Coming Soon |
| 20 | Lookups & Filters | lookup plugins, custom filters | 📝 Coming Soon |
| 21 | Custom Modules | Writing Python modules | 📝 Coming Soon |
| 22 | Ansible Tower/AWX | Web UI, job templates, credentials | 📝 Coming Soon |
| 23 | Best Practices | Directory layout, naming, idempotency | 📝 Coming Soon |
| 24 | Real-World Project | Deploy nginx with SSL, monitoring stack | 📝 Coming Soon |

---

## 🛠️ Prerequisites

Before starting this course, ensure you have:

```bash
# 1. Ansible installed (version 2.15 or higher)
ansible --version

# 2. Python 3.x installed
python3 --version

# 3. SSH client available
ssh -V
```

### Required Knowledge

- 📌 Basic Linux command line
- 📌 Understanding of SSH
- 📌 Basic YAML syntax (we'll cover this too!)

---

## 🖥️ Lab Setup

This course uses **Google Cloud Platform (GCP)** for lab servers. We provide Terraform scripts to provision your lab environment.

### Quick Lab Setup

```bash
# Navigate to the lab provisioning directory
cd util/ansible-lab-servers

# Update terraform.tfvars with your GCP project ID
# Then run:
terraform init
terraform apply
```

### Lab Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Your Local Machine                    │
│                   (Ansible Control Node)                 │
└─────────────────────┬───────────────────────────────────┘
                      │ SSH
                      ▼
┌─────────────────────────────────────────────────────────┐
│                  Google Cloud Platform                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │  ansible-   │ │  ansible-   │ │  ansible-   │       │
│  │  lab-server │ │  lab-server │ │  lab-server │       │
│  │     -1      │ │     -2      │ │     -3      │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
```

### SSH Connection

```bash
ssh -i /path/to/private-key ansible@<SERVER_IP>
```

---

## 🚀 Quick Start

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/rahulwagh/ansible-zero-to-expert-masterclass.git
cd ansible-zero-to-expert-masterclass
```

### 2️⃣ Start with Chapter 01

```bash
cd chapter-01-hello-ansible

# Update inventory with your server IPs
vim inventory

# Run your first playbook
ansible-playbook 01-ping-playbook.yml
```

### 3️⃣ Explore and Learn

Each chapter contains:
- 📄 `README.md` - Chapter instructions
- 📋 `inventory` - Host definitions
- 🎯 `*.yml` - Playbook files
- ⚙️ `ansible.cfg` - Configuration

---

## 📁 Repository Structure

```
ansible-zero-to-expert-masterclass/
│
├── 📖 README.md                    # You are here!
│
├── 📁 chapter-01-hello-ansible/    # Getting started
│   ├── ansible.cfg
│   ├── inventory
│   ├── 01-ping-playbook.yml
│   ├── 02-hello-world-playbook.yml
│   ├── 03-gather-facts-playbook.yml
│   ├── 04-dynamic-host-playbook.yml
│   └── README.md
│
├── 📁 chapter-02-inventory/        # Coming soon...
├── 📁 chapter-03-variables/        # Coming soon...
│   ...
│
└── 📁 util/                        # Utilities
    └── ansible-lab-servers/        # Terraform for lab VMs
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tfvars
```

---

## 💡 Tips for Success

| Tip | Description |
|-----|-------------|
| 🔄 **Practice Daily** | Hands-on practice is key to mastering Ansible |
| 📝 **Take Notes** | Document your learnings and gotchas |
| 🧪 **Experiment** | Modify playbooks and see what happens |
| 🐛 **Debug Fearlessly** | Use `-v`, `-vv`, `-vvv` for verbose output |
| 📚 **Read Docs** | [docs.ansible.com](https://docs.ansible.com) is your friend |

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest new topics
- 📝 Improve documentation
- 🔧 Submit pull requests

---

## 📬 Connect

- 🌐 Website: [yourwebsite.com](https://yourwebsite.com)
- 📺 YouTube: [Your Channel](https://youtube.com)
- 💼 LinkedIn: [Your Profile](https://linkedin.com)

---

<p align="center">
  <strong>Happy Automating! 🚀</strong>
</p>

<p align="center">
  Made with ❤️ by Rahul Wagh
</p>
