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

## The short way (one command)

```bash
cd util/lab-local-docker
./lab.sh up        # creates the key, builds + starts the 3 servers, points every chapter at them, pings
```

`./lab.sh ping`, `./lab.sh stop`, `./lab.sh start`, `./lab.sh down` do what they say.

## The long way (what lab.sh does, step by step)

### 1. Create the SSH key, inside the repo

Everything stays in the repo folder; `util/keys/` is gitignored so the key never gets committed.

```bash
cd util/lab-local-docker
ssh-keygen -t ed25519 -f ../keys/ansible-lab -N ""
```

### 2. Start the lab

```bash
cp .env.example .env            # points at ../keys/ansible-lab.pub
docker compose up -d --build    # first run builds the image (~2 min)
docker compose ps               # all three should be "running"
```

### 3. Test from Ansible

```bash
ansible -i inventory.ini all -m ping
```

### 4. Point every chapter at the lab

```bash
cd ../..                        # repo root
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

- Containers run `privileged` with the host cgroup namespace (`cgroup: host`) because systemd needs that to
  supervise forking services such as MySQL in chapter 10. Normal for this kind of lab; do not expose the SSH
  ports beyond your own machine.
- `cgroup: host` needs Docker Compose v2.15+. On older versions `lab.sh up` starts the same containers with
  plain `docker run --cgroupns=host`, so everything still works.
- `ansible_ssh_private_key_file=../keys/ansible-lab` in `inventory.ini` is relative to this folder, so run
  `ansible -i inventory.ini ...` from here. The chapter inventories get an absolute path from `set-lab-hosts.py`.
- Reboot-style tasks (`reboot` module, kernel changes) do not apply to containers. Everything else
  in the course (apt, service, user, template, copy, file, vault, galaxy) works.
