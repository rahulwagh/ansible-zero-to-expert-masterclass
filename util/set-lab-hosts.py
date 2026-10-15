#!/usr/bin/env python3
"""
Point every chapter's inventory at YOUR lab servers in one go.

Examples
--------
  # Cloud VMs (GCP / AWS / Azure / Multipass): three public IPs (key defaults to util/keys/ansible-lab)
  python3 util/set-lab-hosts.py \
      --server1 34.1.2.3 --server2 34.1.2.4 --server3 34.1.2.5

  # Local Docker lab (util/lab-local-docker): all on 127.0.0.1 with mapped ports
  python3 util/set-lab-hosts.py --docker

  # Only two machines? Reuse one IP for two names
  python3 util/set-lab-hosts.py --server1 10.0.0.5 --server2 10.0.0.5 --server3 10.0.0.6

What it changes in chapter-*/inventory/hosts.ini and chapter-01-hello-ansible/inventory:
  * ansible_host=  for ansible-lab-server-1/2/3 (commented lines stay commented)
  * ansible_port=  added/removed as needed
  * ansible_ssh_private_key_file=  on the [all:vars] / [...:vars] line
Nothing else is touched.
"""
import argparse
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
p.add_argument("--docker", action="store_true", help="use the local Docker lab (127.0.0.1, ports 2221-2223)")
p.add_argument("--key", help="path to the private key (default: util/keys/ansible-lab)")
for n in (1, 2, 3):
    p.add_argument(f"--server{n}", help=f"IP / hostname for ansible-lab-server-{n}")
    p.add_argument(f"--port{n}", type=int, help=f"SSH port for ansible-lab-server-{n} (default 22)")
args = p.parse_args()

DEFAULT_KEY = os.path.join(ROOT, "util", "keys", "ansible-lab")
if args.docker:
    hosts = {n: ("127.0.0.1", 2220 + n) for n in (1, 2, 3)}
else:
    missing = [n for n in (1, 2, 3) if not getattr(args, f"server{n}")]
    if missing:
        p.error("need --server1/--server2/--server3 (or use --docker)")
    hosts = {n: (getattr(args, f"server{n}"), getattr(args, f"port{n}") or 22) for n in (1, 2, 3)}
# absolute path so the inventories work from any directory
key = os.path.abspath(os.path.expanduser(args.key)) if args.key else DEFAULT_KEY
if not os.path.isfile(key):
    print(f"warning: private key not found at {key}\n         create it with: ssh-keygen -t ed25519 -f util/keys/ansible-lab -N ''")

files = sorted(glob.glob(os.path.join(ROOT, "chapter-*", "inventory", "hosts.ini")))
single = os.path.join(ROOT, "chapter-01-hello-ansible", "inventory")
if os.path.isfile(single):
    files.insert(0, single)

host_re = re.compile(r"^(\s*#?\s*)(ansible-lab-server-([123]))(\s+.*)$")
key_re = re.compile(r"^(\s*ansible_ssh_private_key_file\s*=\s*).*$")

changed = 0
for path in files:
    out, touched = [], False
    with open(path) as fh:
        for line in fh:
            raw = line.rstrip("\n")
            m = host_re.match(raw)
            if m:
                prefix, name, n, rest = m.group(1), m.group(2), int(m.group(3)), m.group(4)
                ip, port = hosts[n]
                rest = re.sub(r"\s*ansible_host=\S+", "", rest)
                rest = re.sub(r"\s*ansible_port=\S+", "", rest)
                new = f"{prefix}{name} ansible_host={ip}" + (f" ansible_port={port}" if port != 22 else "") + rest
                if new != raw:
                    touched = True
                out.append(new + "\n")
                continue
            m = key_re.match(raw)
            if m:
                new = f"{m.group(1)}{key}"
                if new != raw:
                    touched = True
                out.append(new + "\n")
                continue
            out.append(line)
    if touched:
        with open(path, "w") as fh:
            fh.writelines(out)
        changed += 1
        print(f"updated  {os.path.relpath(path, ROOT)}")

print(f"\n{changed} inventory file(s) updated. Test with:\n  cd chapter-01-hello-ansible && ansible all -m ping")
sys.exit(0)
