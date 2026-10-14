#!/usr/bin/env bash
# Delete the Multipass lab VMs created by create-lab.sh
set -euo pipefail
VM_COUNT="${VM_COUNT:-3}"
for i in $(seq 1 "$VM_COUNT"); do
  NAME="ansible-lab-server-$i"
  if multipass info "$NAME" >/dev/null 2>&1; then
    echo "==> Deleting $NAME"
    multipass delete "$NAME"
  fi
done
multipass purge
echo "==> Done"
