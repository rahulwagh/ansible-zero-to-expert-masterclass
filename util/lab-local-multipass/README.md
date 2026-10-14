# Local lab with Multipass (free, real Ubuntu VMs on your laptop)

[Multipass](https://multipass.run) is Canonical's free tool that launches real Ubuntu VMs on
macOS, Windows and Linux with one command. The VMs are full systems, so there are no container
limitations at all.

## Requirements

- Multipass installed: `brew install multipass` (macOS), the installer from multipass.run (Windows),
  `snap install multipass` (Linux)
- ~3 GB RAM free for three small VMs (1 CPU, 1 GB RAM, 5 GB disk each)
- Ansible on your machine (see `Ansible_Installation.md` in the repo root)

## 1. Create an SSH key for the lab

```bash
ssh-keygen -t ed25519 -f ~/.ssh/ansible-lab -N ""
```

## 2. Create the VMs

```bash
cd util/lab-local-multipass
chmod +x create-lab.sh destroy-lab.sh
./create-lab.sh                 # uses ~/.ssh/ansible-lab.pub; pass another path as $1 if needed
```

The script launches `ansible-lab-server-1/2/3`, creates the `ansible` user with your key, and
prints a ready-made inventory with the VM IPs.

## 3. Point every chapter at the lab

Use the three IPs the script printed:

```bash
cd ../..   # repo root
python3 util/set-lab-hosts.py --key ~/.ssh/ansible-lab \
    --server1 192.168.64.10 --server2 192.168.64.11 --server3 192.168.64.12
cd chapter-01-hello-ansible && ansible-playbook 01-ping-playbook.yml
```

## Day-to-day

```bash
multipass list                               # IPs and state
multipass stop ansible-lab-server-1          # stop one VM
multipass start --all                        # start everything
./destroy-lab.sh                             # delete all three VMs
```

Tune size with environment variables: `CPUS=2 MEMORY=2G DISK=10G ./create-lab.sh`
