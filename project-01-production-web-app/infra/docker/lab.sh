#!/usr/bin/env bash
# Local lab for the project: 4 systemd containers that behave like VMs.
#
#   ./lab.sh up      create key (if missing), build + start lb-1 app-1 app-2 db-1, ping
#   ./lab.sh ping    ansible ping
#   ./lab.sh stop    pause (keeps everything installed)
#   ./lab.sh start   resume
#   ./lab.sh down    delete the containers (next "up" = fresh servers)
#   ./lab.sh status  list the containers
#
# Uses docker compose when it is v2.15+ (needed for `cgroup: host`); older versions get the
# same containers via plain `docker run --cgroupns=host`. systemd needs the host cgroup namespace
# to supervise forking services such as PostgreSQL.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
KEY="$ROOT/infra/keys/lab"
INV="$ROOT/ansible/inventory/docker.ini"
# every ansible command runs from the ansible/ dir so ansible.cfg and the relative key path in the inventory apply
ans() { (cd "$ROOT/ansible" && ANSIBLE_HOST_KEY_CHECKING=False "$@"); }
IMAGE="ansible-project-node:ubuntu-22.04"
NET="ansible-project"
NODES="lb-1 app-1 app-2 db-1"
cd "$HERE"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1. $2"; exit 1; }; }
compose_ok() {
  local v; v="$(docker compose version --short 2>/dev/null | sed 's/^v//')" || return 1
  [[ -n "$v" ]] && [[ "$(printf '%s\n2.15.0\n' "$v" | sort -V | head -1)" == "2.15.0" ]]
}
ports_for() {  # host port mappings per node
  case "$1" in
    lb-1)  echo "-p 2231:22 -p 8080:80 -p 8443:443" ;;
    app-1) echo "-p 2232:22" ;;
    app-2) echo "-p 2233:22" ;;
    db-1)  echo "-p 2234:22" ;;
  esac
}
run_plain() {
  docker network inspect "$NET" >/dev/null 2>&1 || docker network create "$NET" >/dev/null
  docker build -q -t "$IMAGE" . >/dev/null
  for n in $NODES; do
    docker rm -f "$n" >/dev/null 2>&1 || true
    # shellcheck disable=SC2046
    docker run -d --name "$n" --hostname "$n" --network "$NET" --privileged --cgroupns=host \
      --stop-signal SIGRTMIN+3 --tmpfs /run --tmpfs /run/lock --tmpfs /tmp \
      -v /sys/fs/cgroup:/sys/fs/cgroup:rw -v "$KEY.pub:/home/ansible/.ssh/authorized_keys:ro" \
      $(ports_for "$n") "$IMAGE" >/dev/null
    echo "started $n"
  done
}

case "${1:-}" in
  up)
    need docker "Install Docker Desktop (Mac/Windows) or Docker Engine (Linux)."
    need ansible "Install Ansible first (pip install ansible)."
    docker info >/dev/null 2>&1 || { echo "Docker is installed but not running. Start Docker Desktop and retry."; exit 1; }
    if [[ ! -f "$KEY" ]]; then echo "==> Creating SSH key $KEY"; mkdir -p "$(dirname "$KEY")"; ssh-keygen -t ed25519 -f "$KEY" -N "" -q; fi
    if [[ ! -f "$ROOT/.vault_pass" ]]; then
      echo "==> Creating $ROOT/.vault_pass with the demo vault password (ansible-demo). Change it with: ansible-vault rekey"
      printf 'ansible-demo\n' > "$ROOT/.vault_pass"; chmod 600 "$ROOT/.vault_pass"
    fi
    if compose_ok; then
      [[ -f .env ]] || cp .env.example .env
      echo "==> docker compose: building the node image (first run ~2 min) and starting $NODES"
      docker compose build && docker compose up -d && docker compose ps
    else
      echo "==> docker compose is older than 2.15, using plain docker run (same containers)"
      run_plain
    fi
    echo "==> Waiting for SSH"
    for i in $(seq 1 30); do ssh -i "$KEY" -p 2231 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=2 -o LogLevel=ERROR ansible@127.0.0.1 true 2>/dev/null && break; sleep 2; done
    echo "==> Ping"; ans ansible -i inventory/docker.ini all -m ping
    echo; echo "Lab ready. Deploy the whole stack with:   make site      (or: cd ansible && ansible-playbook site.yml)"
    ;;
  ping)   ans ansible -i inventory/docker.ini all -m ping ;;
  stop)   docker stop $NODES ;;
  start)  docker start $NODES && sleep 3 && ans ansible -i inventory/docker.ini all -m ping ;;
  down)   docker rm -f $NODES >/dev/null 2>&1 || true; docker network rm "$NET" >/dev/null 2>&1 || true; echo "lab removed" ;;
  status) docker ps -a --filter "name=lb-1" --filter "name=app-1" --filter "name=app-2" --filter "name=db-1" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' ;;
  *)      sed -n '2,9p' "$0"; exit 1 ;;
esac
