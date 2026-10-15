#!/usr/bin/env bash
# Create three Ubuntu 22.04 lab VMs with Multipass and print an Ansible inventory.
#
#   ./create-lab.sh [path-to-public-key]      default: ../keys/ansible-lab.pub (repo-local, gitignored)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUB_KEY_FILE="${1:-$SCRIPT_DIR/../keys/ansible-lab.pub}"
VM_COUNT="${VM_COUNT:-3}"
CPUS="${CPUS:-1}"
MEMORY="${MEMORY:-1G}"
DISK="${DISK:-5G}"
IMAGE="${IMAGE:-22.04}"
LAUNCH_TIMEOUT="${LAUNCH_TIMEOUT:-900}"   # seconds; first launch downloads the image

if [[ ! -f "$PUB_KEY_FILE" ]]; then
  echo "Public key not found: $PUB_KEY_FILE"
  echo "Create one with:  ssh-keygen -t ed25519 -f util/keys/ansible-lab -N \"\"   (from the repo root)"
  exit 1
fi
PUB_KEY="$(cat "$PUB_KEY_FILE")"
PRIV_KEY_FILE="$(cd "$(dirname "$PUB_KEY_FILE")" && pwd)/$(basename "${PUB_KEY_FILE%.pub}")"

for i in $(seq 1 "$VM_COUNT"); do
  NAME="ansible-lab-server-$i"
  if multipass info "$NAME" >/dev/null 2>&1; then
    echo "==> $NAME already exists, skipping"
    continue
  fi
  echo "==> Launching $NAME ($IMAGE, ${CPUS} cpu, $MEMORY ram, $DISK disk)"
  sed -e "s|SSH_PUBLIC_KEY_PLACEHOLDER|$PUB_KEY|" \
      -e "s|HOSTNAME_PLACEHOLDER|$NAME|" \
      "$SCRIPT_DIR/cloud-init.yaml" > "/tmp/cloud-init-$NAME.yaml"
  multipass launch "$IMAGE" --name "$NAME" --cpus "$CPUS" --memory "$MEMORY" --disk "$DISK" \
    --timeout "$LAUNCH_TIMEOUT" --cloud-init "/tmp/cloud-init-$NAME.yaml"
  rm -f "/tmp/cloud-init-$NAME.yaml"
done

echo
echo "==> Ansible inventory (save as inventory.ini):"
echo
echo "[webservers]"
for i in $(seq 1 "$VM_COUNT"); do
  [[ $i -eq $VM_COUNT ]] && break
  IP=$(multipass info "ansible-lab-server-$i" --format csv | tail -1 | cut -d, -f3)
  echo "ansible-lab-server-$i ansible_host=$IP"
done
echo
echo "[dbservers]"
IP=$(multipass info "ansible-lab-server-$VM_COUNT" --format csv | tail -1 | cut -d, -f3)
echo "ansible-lab-server-$VM_COUNT ansible_host=$IP"
cat <<EOF

[production:children]
webservers
dbservers

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=$PRIV_KEY_FILE
ansible_python_interpreter=/usr/bin/python3
EOF
