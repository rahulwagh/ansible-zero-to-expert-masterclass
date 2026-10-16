#!/usr/bin/env bash
# Turn Terraform output into ansible/inventory/cloud.ini
#   ./scripts/gen-inventory.sh gcp     (or aws / azure)
set -euo pipefail
CLOUD="${1:?usage: gen-inventory.sh gcp|aws|azure}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/infra/$CLOUD"
terraform output -raw ansible_inventory > "$ROOT/ansible/inventory/cloud.ini"
echo "wrote ansible/inventory/cloud.ini:"; cat "$ROOT/ansible/inventory/cloud.ini"
