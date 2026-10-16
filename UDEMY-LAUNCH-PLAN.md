# Udemy Launch Plan — Ansible course (target: live by Wed 14 Oct 2026)

Course ID on Udemy: 7057851 (currently DRAFT)

---

## 0. Progress log

**Done on Thu 8 Oct 2026 (by Claude, in the built-in browser):**

- ✅ Published all 12 previously-unpublished lectures in sections 5–7 (course now 46 lectures, 4h 23min)
- ✅ Fixed all 10 lecture-title typos (see §5)
- ✅ Course title renamed to **"Ansible Zero to Hero: Playbooks, Templates, Galaxy & Vault"**
- ✅ Landing page filled: subtitle, description, level (All Levels), category (IT & Software → Other IT & Software), topic (Ansible)
- ✅ Intended learners filled: 8 objectives, 5 requirements, 4 audiences
- ✅ Price already set at $39.99 (tier 7) — left as is (plan suggested $49.99; your call)
- ✅ Sections 8–11 created as **unpublished placeholders** with lecture titles already typed in (19 lectures: 4 + 5 + 5 + 5). You only need to click "Add Content" on each and upload the video.
- ✅ Chapter 8 videos downscaled to 1080p: `YouTube/3.---{Ansible-Course}---/ch8/export-1080p/ch8-{1..4}-1080p.mp4` (2.2 GB total)
- ✅ Repo: committed chapters 8/9/11 live-tested changes, README chapter table rewritten (11 chapters, real links), vault password + Galaxy roles gitignored. **Not pushed yet.**

**Still for you (needs file uploads / recording — can't be done from the browser pane):**

1. Upload chapter 8 videos into Section 8 (Lectures 47–50) — mapping in §1 below
2. Upload a course image (750×422, no text) on the landing page
3. Upload a promo video (optional but recommended)
4. Record chapters 9–11 this weekend, upload into the placeholder lectures (Sections 9–11), then click Publish on each lecture
5. Attach the GitHub repo link as a Resource on Lecture 3 (GitHub Repo Walkthrough)
6. `git push` the repo
7. Submit for Review (Monday)

---

## 1. Where things stand (checked 8 Oct 2026)

| Chapter | Repo code + slides | Recorded | On Udemy | Status |
|---|---|---|---|---|
| 01 Hello Ansible | ✅ | ✅ | ✅ Section 1 (9 lectures) | Done |
| 02 Inventory Deep Dive | ✅ | ✅ | ✅ Section 2 (10 lectures) | Done |
| 03 Variables | ✅ | ✅ | ✅ Section 3 (10 lectures) | Done |
| 04 Conditionals | ✅ | ✅ | ✅ Section 4 (5 lectures) | Done |
| 05 Loops | ✅ | ✅ | ⚠️ Uploaded, **3 lectures unpublished** | Click Publish |
| 06 Handlers | ✅ | ✅ | ⚠️ Uploaded, **5 lectures unpublished** | Click Publish |
| 07 Tags | ✅ | ✅ | ⚠️ Uploaded, **4 lectures unpublished** | Click Publish |
| 08 Templates (Jinja2) | ✅ | ✅ 4 files in `YouTube/3.---{Ansible-Course}---/ch8/` (~36 min, 4K) | ❌ Not uploaded | Upload |
| 09 User & Group Mgmt | ✅ | ❌ | ❌ | **Record** |
| 10 Ansible Galaxy | ✅ | ❌ | ❌ | **Record** |
| 11 Ansible Vault | ✅ | ❌ | ❌ | **Record** |

Landing page: **title only**. Subtitle, description, learning objectives, requirements, audience, level, category, course image, promo video, price — all empty.

### Chapter 8 recordings → lecture mapping

| Upload this file (1080p) | Length | Content (verified from frames) | Into Udemy lecture (already created) |
|---|---|---|---|
| `ch8/export-1080p/ch8-1-1080p.mp4` | 12:01 | Slides: what is the template module, Jinja2 intro | Lecture 47: Templates with Jinja2 - Introduction |
| `ch8/export-1080p/ch8-2-1080p.mp4` | 6:50 | `01-template-basics.yml` walkthrough (nginx.conf.j2) | Lecture 48: Template Basics - Deploy an nginx Config |
| `ch8/export-1080p/ch8-3-1080p.mp4` | 5:08 | `02-jinja2-filters.yml` | Lecture 49: Jinja2 Filters |
| `ch8/export-1080p/ch8-4-1080p.mp4` | 11:37 | `03-templates-practical.yml` (pre_tasks, full stack) | Lecture 50: Templates in Practice - Full App Deployment |

The 1080p exports are already made (originals were 4K, 4.3 GB; exports are 2.2 GB). Use the `export-1080p` files.

---

## 2. The title problem (this is what will cost you ratings)

Current title: **"Ansible Zero To Hero: Tower, Galaxy & Enterprise Automation"**

It promises Tower/AWX and "enterprise automation". Neither exists in the repo or recordings, and
neither can be built by Wednesday. Students who buy for Tower and don't get it leave 1–2 star reviews.
Rename the title to match what ships. Options (all ≤ 60 chars):

1. `Ansible Zero to Hero: Playbooks, Templates, Galaxy & Vault` (58)
2. `Ansible Zero to Hero: Hands-On Automation from Scratch` (54)
3. `Ansible for DevOps: Playbooks, Jinja2, Galaxy & Vault` (53)

Recommended: **Option 1** if chapters 9–11 get recorded, **Option 2** if launching with 1–8 only.

---

## 3. Day-by-day plan

| Day | Tasks |
|---|---|
| **Thu 8 Oct** | Publish the 12 unpublished lectures in sections 5–7. Fix lecture-title typos (see §5). Fill landing page from §4 (subtitle, description, objectives, requirements, audience, level, category, topic). Set price. |
| **Fri 9 Oct** | Upload chapter 8 (4 videos) as Section 8. Create course image (750×422, no text). Pick promo video. Commit the pending repo changes and fix README. |
| **Sat 10 Oct** | Record chapter 9 (User & Group) and chapter 10 (Galaxy). Code and slides already exist and were live-tested. |
| **Sun 11 Oct** | Record chapter 11 (Vault). Upload chapters 9–11. |
| **Mon 12 Oct** | Final review in Udemy preview. Attach GitHub link as a resource on lecture 3. **Submit for Review.** |
| **Tue–Wed 13–14 Oct** | Udemy review usually takes 1–2 business days. Fix any review feedback. Course goes live. |

**Fallback:** if recording slips, submit Monday with chapters 1–8 and title option 2. Add 9–11 as a free update later (Udemy lets you add sections after launch and students get notified — that *gains* ratings, it doesn't lose them).

### Suggested lecture split for chapters 9–11 (one video per playbook, same as ch 8)

**Section 9: User & Group Management**
1. User & Group Management — Introduction (slides)
2. User Basics — `01-user-basics.yml`
3. Group Management — `02-group-management.yml`
4. SSH Keys with authorized_key — `03-authorized-keys.yml`
5. User & Group in Practice — `04-user-group-practical.yml`

**Section 10: Ansible Galaxy**
1. Ansible Galaxy — Introduction (slides)
2. Install a Role from Galaxy — `01-install-role.yml`
3. Install a Collection — `02-install-collection.yml`
4. requirements.yml — `03-requirements.yml`
5. Galaxy in Practice — `04-galaxy-practical.yml`

**Section 11: Ansible Vault**
1. Ansible Vault — Introduction (slides)
2. Vault Basics: encrypt, decrypt, view, edit — `01-vault-basics.yml`
3. encrypt_string — `02-encrypt-string.yml`
4. Vault Password File & Vault IDs — `03-vault-password-file.yml`
5. Vault in Practice — `04-vault-practical.yml`

---

## 4. Landing page copy (paste into Udemy)

### Course subtitle (≤120 chars)

`Master Ansible playbooks, inventory, variables, loops, handlers, Jinja2 templates, Galaxy & Vault with real cloud labs`

### Course description (≥200 words)

Ansible is the most widely used configuration management and automation tool in DevOps, and this course takes you from zero to confidently writing production-style playbooks.

Every chapter is hands-on. You will run every playbook against real Linux servers provisioned on Google Cloud (Terraform scripts included), and all code lives in a public GitHub repository that you clone and follow along with.

**What you will build and learn**

- Install Ansible on Linux and Windows (WSL) and understand the control node / managed node architecture
- Write your first playbook, use ad-hoc commands, gather facts and target hosts dynamically
- Master inventory: static INI and YAML inventories, groups, nested groups, host patterns (intersection, exclusion, wildcards, regex) and `--limit`
- Use every kind of variable: inline vars, vars_files, group_vars, host_vars, extra vars, registered variables, facts and magic variables, and understand variable precedence
- Control execution with conditionals (`when`, `failed_when`, `changed_when`), loops (`loop`, `with_dict`, `loop_control`), handlers (`notify`, `listen`, `flush_handlers`) and tags
- Generate dynamic configuration files with Jinja2 templates and filters, and deploy a full nginx + app configuration
- Manage Linux users, groups and SSH keys with `user`, `group` and `authorized_key`
- Reuse community content from Ansible Galaxy: roles, collections and `requirements.yml`
- Protect secrets with Ansible Vault: encrypt files, `encrypt_string`, vault password files and vault IDs

**Who this is for**

Beginners with basic Linux and SSH knowledge, system administrators who want to stop doing repetitive work by hand, and DevOps or cloud engineers who need Ansible for infrastructure automation. No prior Ansible experience is required.

**What you get**

- 50+ video lectures organised into 11 chapters
- A GitHub repository with every playbook, inventory, template and slide deck
- Terraform code to spin up your own lab servers in minutes
- Lifetime access and future chapter updates at no extra cost

By the end you will be able to automate real server configuration tasks with Ansible and read, debug and extend any playbook you encounter at work.

### What will students learn (≤160 chars each, need ≥4)

1. Write Ansible playbooks from scratch and run them against real cloud servers
2. Build and organise inventories with groups, host patterns and variables (group_vars, host_vars, facts, magic variables)
3. Control playbook flow with conditionals, loops, handlers and tags
4. Generate dynamic config files with Jinja2 templates and filters
5. Manage Linux users, groups and SSH keys with Ansible
6. Reuse community roles and collections from Ansible Galaxy using requirements.yml
7. Encrypt passwords and secrets with Ansible Vault, encrypt_string and vault password files
8. Set up a cloud-based Ansible lab with Terraform

### Requirements

1. Basic Linux command-line knowledge (cd, ls, editing a file)
2. Familiarity with SSH
3. A computer running Linux, macOS, or Windows with WSL
4. A free-tier Google Cloud or any Linux VMs for the labs (Terraform scripts provided)
5. No prior Ansible experience needed

### Who is this course for

1. Beginners who want to learn Ansible and configuration management from scratch
2. System administrators who want to automate repetitive server tasks
3. DevOps and cloud engineers adding Ansible to their toolkit
4. Developers who need to understand and modify Ansible playbooks at work

### Basic info

- Language: English (US)
- Level: All Levels (or Beginner)
- Category: IT & Software → Other IT & Software
- Topic: Ansible
- Price: $49.99 (tier 9) — your AWS course is $64.99 and Azure €49.99; this is shorter, so price slightly under.

### Promo video

Candidate: `YouTube/3.---{Ansible-Course}---/Export/1-ansible-intro.mp4` (3:30). Udemy recommends under 2 minutes; trim to the first ~90 seconds or re-record a 60–90 s pitch.

---

## 5. Lecture title typos on Udemy (fix before submitting — reviewers and students notice)

| Lecture | Current | Change to |
|---|---|---|
| 7 | Hello Work Playbook | Hello World Playbook |
| 13–16 | Hosts selection pattern / Hosts selection Pattern / Host Selection Pattern | Host Selection Pattern: Intersection / Exclusion / Wildcards / Regex |
| 21 | Vars Files(Variables File) | Vars Files (Variables Files) |
| 24 | Variables Precendence | Variable Precedence |
| 27 | Ansible Facts As a Variables | Ansible Facts as Variables |
| 29 | Ansible Variables Scopes | Ansible Variable Scopes |
| 31 | Multiple Conditional AND (list), OR, complex conditions | Multiple Conditions: AND, OR and Complex Expressions |
| 33 | Failed when conditional | failed_when and changed_when |
| Sec 6 | Flust Handlers | Flush Handlers |
| Sec 7 | Tag Inheritence | Tag Inheritance |

---

## 6. Repo tidy-up (so the GitHub link in lecture 3 matches the videos)

1. Commit the pending changes in chapters 8, 9, 11 (they're the live-tested versions shown on screen).
2. Add `chapter-11-ansible-vault/vaul_pass_file/` to `.gitignore` (contains a vault password) — or delete the folder.
3. README chapter table: currently says 23 chapters, lists chapter 12 twice, and has Vault as "Coming Soon" at #16 although it shipped as #11. Replace with the 11 real chapters and move the rest under a "Planned" heading.
4. README footer still has placeholder links (yourwebsite.com, "Your Channel"). Point them to your real YouTube/LinkedIn.
5. README badge says "Chapters-23"; change to 11.

---

## 7. Udemy article lecture: "Set Up Your Lab Servers" (paste as a text lecture, Section 1, right after the intro)

**Title:** Set Up Your Lab Servers (Local, Cloud or Free)

---

Every playbook in this course runs against three Ubuntu 22.04 servers called **ansible-lab-server-1, -2 and -3**. You can run them anywhere. Pick ONE of these, they all behave identically for the course:

**Option A: Docker on your laptop (free, fastest, recommended to start)**
Three lightweight containers with systemd and SSH. Five minutes to set up, works offline.

**Option B: Multipass VMs on your laptop (free)**
Real Ubuntu VMs via Canonical's free Multipass tool. Needs about 3 GB of RAM.

**Option C: Google Cloud (used in the videos)**
Terraform scripts included. One e2-micro is always free; new accounts get $300 credit.

**Option D: AWS** / **Option E: Azure**
Terraform scripts included for both. Free-tier eligible instance sizes are pre-selected.

**Option F: Other free options**
Oracle Cloud Always Free (the most generous permanent free tier), GitHub Codespaces (60 free hours a month, Docker pre-installed), or any Linux box you can SSH into.

The full step-by-step guide for every option, with copy-paste commands, is here:

https://github.com/rahulwagh/ansible-zero-to-expert-masterclass/blob/main/LAB-SETUP.md

**Quick start with Docker:**

1. Install Ansible on your machine (Ansible_Installation.md in the repo).
2. Create an SSH key: `ssh-keygen -t ed25519 -f ~/.ssh/ansible-lab -N ""`
3. `cd util/lab-local-docker && cp .env.example .env && docker compose up -d --build`
4. `cd ../.. && python3 util/set-lab-hosts.py --docker`
5. `cd chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml`

The `set-lab-hosts.py` helper points every chapter's inventory at your servers in one command, so you never edit IPs by hand. Run it again whenever your IPs change.

In the videos you will see me use Google Cloud VMs with public IPs. Your IPs, ports and key path will be different, and that is the only difference. Everything else is identical.

Stuck? Check the Troubleshooting table at the bottom of LAB-SETUP.md, then ask in the Q&A.

---

## 8. Recording script: "Run the Lab on Your Laptop with Docker (Mac, Windows, Linux)"

Place: Section 1, right after Lecture 4 (the lab setup article). Target length 10–12 min. Free preview: yes (it removes the #1 reason people refund: "I can't set up the lab").

### Before you hit record
- Docker Desktop running (whale icon steady). Cached lab image already removed so the build is real on camera.
- The key lives inside the repo at `util/keys/ansible-lab` (gitignored). A fresh clone has no key, so you create it on camera.
- Record in a fresh clone under `~/Downloads/ansible-demo/`, NOT in your working repo, so `set-lab-hosts.py` doesn't overwrite your GCP inventories.
- Terminal: big font, one window, `clear` between sections. Keep the browser ready for http://localhost:8081.

### Shot list (say / type)

**0. Hook (30 s)** — "You don't need a cloud account for this course. In 10 minutes you'll have the same three servers I use, running on your laptop, for free. Mac, Windows or Linux, same commands."

**1. Prerequisites (1 min)**
```bash
docker --version
docker compose version
ansible --version
```
Say: Docker Desktop on Mac/Windows, Docker Engine on Linux. Ansible installed as shown in the two installation lectures.
Windows note (say it, you can't show it): open the **WSL / Ubuntu terminal**, not PowerShell. In Docker Desktop → Settings → Resources → WSL integration, enable your Ubuntu distro. After that every command in this video is identical.

**2. Clone (1 min)**
```bash
cd ~/Downloads/ansible-demo
git clone https://github.com/rahulwagh/ansible-zero-to-expert-masterclass.git
cd ansible-zero-to-expert-masterclass
ls
```
Open `LAB-SETUP.md` briefly: "every option is documented here; today we do Option A."

**3. SSH key, inside the repo (1 min)**
```bash
ssh-keygen -t ed25519 -f util/keys/ansible-lab -N ""
ls util/keys
cat util/keys/ansible-lab.pub
```
Say: Ansible talks to servers over SSH. This public key gets installed inside every lab server; the private key stays here in the repo folder. `util/keys` is gitignored so you can never commit it by accident. Everything for the course lives in this one folder.

**4. Start the lab (3 min)**
```bash
cd util/lab-local-docker
cat docker-compose.yml
```
Walk through: three services named like the course servers; `privileged` because they run real systemd; SSH on 2221/2222/2223, HTTP on 8081/8082/8083; your public key mounted as `authorized_keys`.
```bash
cp .env.example .env
cat .env                 # SSH_PUBLIC_KEY_FILE=../keys/ansible-lab.pub
docker compose up -d --build
```
Build takes ~2 min: speed this up in the edit. Then:
```bash
docker compose ps
docker exec ansible-lab-server-1 systemctl is-active ssh
docker exec ansible-lab-server-1 systemctl list-units --type=service --no-pager | head
```
(Avoid `systemctl status` on camera: on Docker Desktop it prints a harmless "Failed to dump process list ... Input/output error" line before the real output.)
Say: that's real systemd inside the container, so `service`, `apt`, `user`, everything in the course works exactly like on a VM.

**5. First contact (1 min)**
```bash
cat inventory.ini
ansible -i inventory.ini all -m ping
```
Three green SUCCESS. Point at `ansible_host=127.0.0.1` + `ansible_port`: "same machine, different door."

**6. Wire every chapter to the lab (2 min)**
```bash
cd ../..
python3 util/set-lab-hosts.py --docker
git diff chapter-01-hello-ansible/inventory
cd chapter-01-hello-ansible
ansible-playbook 01-ping-playbook.yml
ansible-playbook 03-gather-facts-playbook.yml
```
Say: one command rewrote all eleven chapter inventories. When you see my Google Cloud IPs in later videos, yours say 127.0.0.1 with a port. That is the only difference.

**7. Prove it's a real server (1 min, the wow moment)**
```bash
ansible webservers -b -m apt -a "name=nginx state=present update_cache=yes"
ansible webservers -b -m service -a "name=nginx state=started enabled=yes"
```
(You're still in chapter-01-hello-ansible, so its inventory is used.) Open http://localhost:8081 and http://localhost:8082 → nginx welcome page. "Two web servers, installed and started by Ansible, on your laptop. That second command is systemd inside a container, which is why this lab behaves like real VMs."

**8. Day-to-day (1 min)**
```bash
cd ../util/lab-local-docker
docker compose stop      # pause, keeps everything
docker compose start     # resume
docker compose down      # delete, next 'up' gives fresh servers
```
Say: unlike cloud VMs the addresses never change, so you never re-run set-lab-hosts.

**8b. The shortcut (30 s)**
Say: everything you just typed is wrapped in one script for next time:
```bash
./lab.sh up      # key + build + start + wire chapters + ping
./lab.sh down
```

**9. Outro (30 s)** — "If you'd rather use Google Cloud, AWS or Azure, the Terraform scripts and instructions are in the same LAB-SETUP file, and the course videos use Google Cloud. Otherwise, you're done: next lecture we write the first playbook."

### After recording
```bash
cd ~/Downloads/ansible-demo/ansible-zero-to-expert-masterclass/util/lab-local-docker && docker compose down
rm -rf ~/Downloads/ansible-demo/ansible-zero-to-expert-masterclass   # optional
```
Your working repo at `my-code-base/` is untouched.

### Platform notes to mention once (no need to show)
- Apple Silicon: builds an arm64 image automatically, nothing to change.
- Windows: WSL2 + Docker Desktop with WSL integration; keys and clone live inside WSL (`~` of the Ubuntu distro).
- Linux: Docker Engine + compose plugin; add your user to the `docker` group or prefix with `sudo`.

---

## 9. YouTube community post: promo video

**Render:** `YouTube/3.---{Ansible-Course}---/youtube-communitypost/export/ansible-course-promo-final-1080p.mp4`
(1920×1080, 30 fps, H.264 + AAC; Remotion composition `AnsibleCoursePromo` in `my-code-base/remotion-flow-diagrams`, source talking head at `public/video/ansible-promo/talking-head.mp4`).

**How to post:** YouTube community posts can't host a raw video file. Upload the render as a normal video
(public or unlisted), then create the community post → "Video" → pick it. Same 1080p file works for the
YouTube video itself, a LinkedIn post and X.

**Post text (copy/paste):**

I just launched my Ansible Masterclass on Udemy 🎉 — the course I wish I had when I started.

✅ 7+ hours, 65+ hands-on lectures
✅ Playbooks, inventory, variables, loops, handlers, tags
✅ Jinja2 templates, Ansible Galaxy, Ansible Vault
✅ Real-world project at the end
✅ Run the labs on your laptop with Docker (free), or on GCP / AWS / Azure — scripts included
✅ Every slide, note and playbook is in the GitHub repo. No note-taking needed.

👉 Course: https://www.udemy.com/course/ansible-zero-to-hero-masterclass/
👉 Code + slides: https://github.com/rahulwagh/ansible-zero-to-expert-masterclass

Updating it every week — tell me what you want added next. See you in the course!

**Video title (if uploaded as a video):** Ansible Zero to Hero — my new Udemy Masterclass is live
**Tags:** ansible, ansible tutorial, devops, configuration management, udemy course
