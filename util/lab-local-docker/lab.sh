#!/usr/bin/env bash
# One-command local lab for the course.
#
#   ./lab.sh up      create the SSH key (if missing), build + start the 3 servers,
#                    point every chapter's inventory at them, run a ping
#   ./lab.sh ping    ansible ping against the 3 servers
#   ./lab.sh stop    pause the servers (keeps everything installed)
#   ./lab.sh start   resume paused servers
#   ./lab.sh down    delete the servers (next "up" gives you fresh ones)
#   ./lab.sh status  docker compose ps
#
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
KEY="$ROOT/util/keys/ansible-lab"
cd "$HERE"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1. $2"; exit 1; }; }
compose_ok() {
  local v; v="$(docker compose version --short 2>/dev/null | sed 's/^v//')" || return 1
  [[ -n "$v" ]] && [[ "$(printf '%s\n2.15.0\n' "$v" | sort -V | head -1)" == "2.15.0" ]]
}
IMAGE="ansible-lab-node:ubuntu-22.04"; NET="ansible-lab"; NODES="ansible-lab-server-1 ansible-lab-server-2 ansible-lab-server-3"
run_plain() {
  docker network inspect "$NET" >/dev/null 2>&1 || docker network create "$NET" >/dev/null
  docker build -q -t "$IMAGE" . >/dev/null
  local i=1
  for n in $NODES; do
    docker rm -f "$n" >/dev/null 2>&1 || true
    docker run -d --name "$n" --hostname "$n" --network "$NET" --privileged --cgroupns=host \
      --stop-signal SIGRTMIN+3 --tmpfs /run --tmpfs /run/lock --tmpfs /tmp \
      -v /sys/fs/cgroup:/sys/fs/cgroup:rw -v "$KEY.pub:/home/ansible/.ssh/authorized_keys:ro" \
      -p "222$i:22" -p "808$i:80" "$IMAGE" >/dev/null
    echo "started $n"; i=$((i+1))
  done
}

case "${1:-}" in
  up)
    need docker "Install Docker Desktop (Mac/Windows) or Docker Engine (Linux)."
    need ansible "Install Ansible first (see Ansible_Installation.md in the repo root)."
    docker info >/dev/null 2>&1 || { echo "Docker is installed but not running. Start Docker Desktop and retry."; exit 1; }

    if [[ ! -f "$KEY" ]]; then
      echo "==> Creating SSH key $KEY"
      mkdir -p "$(dirname "$KEY")"
      ssh-keygen -t ed25519 -f "$KEY" -N "" -q
    else
      echo "==> Using existing SSH key $KEY"
    fi

    [[ -f .env ]] || cp .env.example .env
    if compose_ok; then
      echo "==> Building the lab image (first run takes ~2 min)"
      docker compose build
      echo "==> Starting ansible-lab-server-1/2/3"
      docker compose up -d
      docker compose ps
    else
      echo "==> docker compose is older than 2.15 (no 'cgroup: host' support); starting the same containers with docker run"
      run_plain
    fi

    echo "==> Pointing every chapter's inventory at the local lab"
    python3 "$ROOT/util/set-lab-hosts.py" --docker

    echo "==> Waiting for SSH"
    for i in $(seq 1 30); do
      if ssh -i "$KEY" -p 2221 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
             -o ConnectTimeout=2 -o LogLevel=ERROR ansible@127.0.0.1 true 2>/dev/null; then break; fi
      sleep 2
    done

    echo "==> Ping"
    ANSIBLE_HOST_KEY_CHECKING=False ansible -i inventory.ini all -m ping
    echo
    echo "Lab is ready. Try:  cd $ROOT/chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml"
    ;;
  ping)   ANSIBLE_HOST_KEY_CHECKING=False ansible -i inventory.ini all -m ping ;;
  stop)   docker stop $NODES ;;
  start)  docker start $NODES && sleep 3 && ANSIBLE_HOST_KEY_CHECKING=False ansible -i inventory.ini all -m ping ;;
  down)   docker rm -f $NODES >/dev/null 2>&1 || true; docker network rm "$NET" >/dev/null 2>&1 || true; echo "lab removed" ;;
  status) docker ps -a --filter "name=ansible-lab-server" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" ;;
  *)      sed -n '2,10p' "$0"; exit 1 ;;
esac
