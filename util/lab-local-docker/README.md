# Local lab with Docker (free, runs on your laptop)

Three Ubuntu 22.04 containers that behave like small servers: they run **systemd**, **sshd** and
**Python**, so every playbook in the course works against them exactly as it would against a cloud VM.

| Container | SSH | HTTP (nginx chapters) |
|---|---|---|
| ansible-lab-server-1 | `127.0.0.1:2221` | http://localhost:8081 |
| ansible-lab-server-2 | `127.0.0.1:2222` | http://localhost:8082 |
| ansible-lab-server-3 | `127.0.0.1:2223` | http://localhost:8083 |

## Requirements

- Docker Desktop 4.x or newer (macOS, Windows with WSL 2) or Docker Engine 20.10+ on Linux, with
  Docker Compose v2 (`docker compose version`)
- Ansible on your machine (see `Ansible_Installation.md` in the repo root)

## 1. Create an SSH key for the lab

```bash
ssh-keygen -t ed25519 -f ~/.ssh/ansible-lab -N ""
```

## 2. Start the lab

```bash
cd util/lab-local-docker
cp .env.example .env            # points at ~/.ssh/ansible-lab.pub, edit if you used another path
docker compose up -d --build    # first run builds the image (~2 min)
docker compose ps               # all three should be "running"
```

## 3. Test from Ansible

```bash
ansible -i inventory.ini all -m ping
```

## 4. Point every chapter at the lab

From the repo root:

```bash
python3 util/set-lab-hosts.py --docker
cd chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml
```

## Stop / reset

```bash
docker compose stop          # pause, keeps state
docker compose start         # resume
docker compose down          # delete the containers (fresh servers on next "up")
```

## Notes

- Containers run `privileged` because systemd needs it. That is normal for this kind of lab; do not
  expose the SSH ports beyond your own machine.
- On a Linux host that still uses cgroup v1, add `cgroup: host` under `x-lab-node` in
  `docker-compose.yml` if systemd fails to start.
- Reboot-style tasks (`reboot` module, kernel changes) do not apply to containers. Everything else
  in the course (apt, service, user, template, copy, file, vault, galaxy) works.
