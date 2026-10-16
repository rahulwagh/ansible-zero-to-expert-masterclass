<p align="center">
  <img src="./assets/ansible-logo.png" alt="Ansible Logo" width="160"/>
</p>

<h1 align="center">Ansible Zero to Expert Masterclass</h1>

<p align="center">
  <strong>From Your First Playbook to Production-Ready Automation</strong>
</p>

<p align="center">
  <a href="#-course-overview">Overview</a> •
  <a href="#-chapters">Chapters</a> •
  <a href="#-prerequisites">Prerequisites</a> •
  <a href="./LAB-SETUP.md">Lab Setup</a> •
  <a href="#-quick-start">Quick Start</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Ansible-2.15+-red?style=for-the-badge&logo=ansible" alt="Ansible"/>
  <img src="https://img.shields.io/badge/Level-Beginner%20to%20Expert-blue?style=for-the-badge" alt="Level"/>
  <img src="https://img.shields.io/badge/Chapters-11-green?style=for-the-badge" alt="Chapters"/>
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

### 🟢 Foundation (Chapters 1-4)

| # | Chapter | Description | Status |
|---|---------|-------------|--------|
| 01 | [Hello Ansible](./chapter-01-hello-ansible/) | Installation, architecture, your first playbook, ping, debug, facts | ✅ Ready |
| 02 | [Inventory Deep Dive](./chapter-02-inventory-deep-dive/) | Static inventory, groups, host patterns, `--limit` | ✅ Ready |
| 03 | [Variables](./chapter-03-variables/) | vars, vars_files, host_vars, group_vars, precedence, facts, magic variables | ✅ Ready |
| 04 | [Conditionals](./chapter-04-conditionals/) | when, failed_when, changed_when, multiple conditions | ✅ Ready |

### 🟡 Intermediate (Chapters 5-8)

| # | Chapter | Description | Status |
|---|---------|-------------|--------|
| 05 | [Loops](./chapter-05-loops/) | loop, with_items, with_dict, loop_control | ✅ Ready |
| 06 | [Handlers](./chapter-06-handlers/) | handlers, notify, listen, flush_handlers | ✅ Ready |
| 07 | [Tags](./chapter-07-tags/) | tags, always, never, --tags, --skip-tags | ✅ Ready |
| 08 | [Templates](./chapter-08-templates/) | Jinja2 templates, filters, template module | ✅ Ready |

### 🟠 Advanced (Chapters 9-11)

| # | Chapter | Description | Status |
|---|---------|-------------|--------|
| 09 | [User & Group Management](./chapter-09-user-group-management/) | user, group, authorized_key | ✅ Ready |
| 10 | [Ansible Galaxy](./chapter-10-ansible-galaxy/) | Install roles, collections, requirements.yml | ✅ Ready |
| 11 | [Ansible Vault](./chapter-11-ansible-vault/) | encrypt, decrypt, encrypt_string, vault password file, vault IDs | ✅ Ready |

### 🏗️ Real-World Projects

| # | Project | What you build | Runs on |
|---|---------|----------------|---------|
| 01 | [Production Web App: Terraform + Ansible + CI/CD](./project-01-production-web-app/) | nginx load balancer with Let's Encrypt, two app servers (Flask + gunicorn + systemd), PostgreSQL with Vault secrets, zero-downtime rolling deploy, GitHub Actions | Docker on your laptop, GCP, AWS, Azure |

---

### 🔮 Planned Future Chapters

File & package management, service management, blocks & error handling, roles, dynamic inventory, lookups & filters, custom modules, AWX / Automation Controller, best practices and a real-world capstone project. These will be added as free updates.

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

Every chapter runs against **three Ubuntu 22.04 servers**. Run them wherever suits you; the playbooks
don't care. Full instructions for each option are in **[LAB-SETUP.md](./LAB-SETUP.md)**.

| Option | Cost | Folder |
|---|---|---|
| 🐳 Docker on your laptop (fastest, works offline) | Free | [`util/lab-local-docker`](./util/lab-local-docker/) |
| 💻 Multipass VMs on your laptop | Free | [`util/lab-local-multipass`](./util/lab-local-multipass/) |
| ☁️ Google Cloud (used in the videos) | Free tier / ~$0.03 per hour | [`util/lab-gcp`](./util/lab-gcp/) |
| ☁️ AWS | Free tier / ~$0.03 per hour | [`util/lab-aws`](./util/lab-aws/) |
| ☁️ Azure | Free tier / ~$0.03 per hour | [`util/lab-azure`](./util/lab-azure/) |
| 🆓 Oracle Always Free, GitHub Codespaces, any VPS | Free | see LAB-SETUP.md |

### Quick start (Docker)

```bash
cd util/lab-local-docker && ./lab.sh up        # key + 3 servers + inventories, ~2 min
cd ../../chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml
```

### Lab Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Your Local Machine                    │
│                   (Ansible Control Node)                 │
└─────────────────────┬───────────────────────────────────┘
                      │ SSH (user: ansible, key: util/keys/ansible-lab)
                      ▼
┌─────────────────────────────────────────────────────────┐
│     Docker / Multipass / GCP / AWS / Azure / any VM      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │  ansible-   │ │  ansible-   │ │  ansible-   │       │
│  │  lab-server │ │  lab-server │ │  lab-server │       │
│  │     -1      │ │     -2      │ │     -3      │       │
│  │ [webservers]│ │ [webservers]│ │ [dbservers] │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
```

Point every chapter's inventory at your servers in one command:

```bash
python3 util/set-lab-hosts.py --server1 <ip> --server2 <ip> --server3 <ip>
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

# Point the inventory at your lab servers (see LAB-SETUP.md)
python3 ../util/set-lab-hosts.py --docker      # or --key ... --server1 ... --server2 ... --server3 ...

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
├── 📁 chapter-02-inventory-deep-dive/  # Inventory mastery
│   ├── ansible.cfg
│   ├── inventory/
│   │   ├── hosts.ini
│   │   ├── 01-basic-inventory.ini
│   │   ├── 02-groups-inventory.ini
│   │   └── ... (6 inventory examples)
│   ├── 01-target-all-hosts.yml
│   ├── ... (10 playbooks)
│   └── README.md
│
├── 📁 chapter-03-variables/            # Variables mastery
│   ├── ansible.cfg
│   ├── inventory/
│   ├── group_vars/
│   │   ├── all.yml
│   │   ├── webservers.yml
│   │   └── dbservers.yml
│   ├── host_vars/
│   ├── vars/
│   ├── 01-vars-inline.yml
│   ├── ... (10 playbooks)
│   └── README.md
│
├── 📁 chapter-04-conditionals/         # Conditionals
│   ├── ansible.cfg
│   ├── inventory/
│   ├── 01-when-basics.yml
│   ├── ... (5 playbooks)
│   └── README.md
│
├── 📁 chapter-05-loops/                # Loops
│   ├── ansible.cfg
│   ├── inventory/
│   ├── 01-loop-basics.yml
│   ├── ... (4 playbooks)
│   └── README.md
│
├── 📁 chapter-06-handlers/             # Handlers
│   ├── ansible.cfg
│   ├── inventory/
│   ├── 01-handler-basics.yml
│   ├── ... (4 playbooks)
│   └── README.md
│
├── 📁 chapter-07-tags/                 # Tags
│   ├── ansible.cfg
│   ├── inventory/
│   ├── 01-tag-basics.yml
│   ├── ... (4 playbooks)
│   └── README.md
│
├── 📁 chapter-08-templates/            # Templates with Jinja2
│   ├── ansible.cfg
│   ├── inventory/
│   ├── templates/
│   │   ├── nginx.conf.j2
│   │   ├── app.conf.j2
│   │   ├── motd.j2
│   │   ├── index.html.j2
│   │   └── sudoers_snippet.j2
│   ├── 01-template-basics.yml
│   ├── 02-jinja2-filters.yml
│   ├── 03-templates-practical.yml
│   └── README.md
│
├── 📁 chapter-09-user-group-management/  # User & Group Management
│   ├── ansible.cfg
│   ├── inventory/
│   ├── files/
│   │   └── id_rsa_devops.pub
│   ├── 01-user-basics.yml
│   ├── 02-group-management.yml
│   ├── 03-authorized-keys.yml
│   ├── 04-user-group-practical.yml
│   └── README.md
│
├── 📁 chapter-10-ansible-galaxy/       # Ansible Galaxy
│   ├── ansible.cfg
│   ├── inventory/
│   ├── slides/
│   │   ├── chapter-10-presentation.md
│   │   └── chapter-10-presentation.pptx
│   ├── 01-install-role.yml
│   ├── 02-install-collection.yml
│   ├── 03-requirements.yml
│   ├── 04-galaxy-practical.yml
│   └── README.md
│
├── 📁 chapter-11-ansible-vault/        # Ansible Vault
│   ├── ansible.cfg
│   ├── inventory/
│   ├── vars/
│   │   ├── secret_vars.yml
│   │   └── app_config.yml
│   ├── slides/
│   │   ├── chapter-11-presentation.md
│   │   └── chapter-11-presentation.pptx
│   ├── 01-vault-basics.yml
│   ├── 02-encrypt-string.yml
│   ├── 03-vault-password-file.yml
│   ├── 04-vault-practical.yml
│   └── README.md
│
├── 📖 LAB-SETUP.md                 # Where to run the playbooks (local / cloud / free options)
│
├── 📁 project-01-production-web-app/   # Real-world project: Terraform + Ansible + CI/CD (Docker / GCP / AWS / Azure)
│
└── 📁 util/                        # Lab environments
    ├── keys/                       # Your lab SSH key pair (gitignored)
    ├── set-lab-hosts.py            # Point every chapter at your servers
    ├── lab-local-docker/           # 3 systemd containers on your laptop (free)
    ├── lab-local-multipass/        # 3 Ubuntu VMs on your laptop (free)
    ├── lab-gcp/                    # Terraform: Google Cloud (used in the videos)
    ├── lab-aws/                    # Terraform: AWS
    └── lab-azure/                  # Terraform: Azure
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

- 🌐 Website: [jhooq.com](https://jhooq.com)
- 📺 YouTube: [@RahulWagh](https://www.youtube.com/@RahulWagh)
- 💼 LinkedIn: [rahul-wagh](https://www.linkedin.com/in/rahul-wagh/)

---

<p align="center">
  <strong>Happy Automating! 🚀</strong>
</p>

<p align="center">
  Made with ❤️ by Rahul Wagh
</p>

