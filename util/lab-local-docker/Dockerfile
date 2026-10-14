# Ansible lab node: Ubuntu 22.04 + systemd + SSH + Python
# Behaves like a small VM so every playbook in the course (service, apt, user, template ...) works.
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG SSH_USER=ansible

RUN apt-get update && apt-get install -y --no-install-recommends \
      systemd systemd-sysv dbus \
      openssh-server sudo \
      python3 python3-apt \
      ca-certificates curl iproute2 iputils-ping less vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Strip systemd units that cannot run inside a container
RUN find /lib/systemd/system/sysinit.target.wants/ -mindepth 1 ! -name 'systemd-tmpfiles-setup.service' -delete \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
             /etc/systemd/system/*.wants/* \
             /lib/systemd/system/local-fs.target.wants/* \
             /lib/systemd/system/sockets.target.wants/*udev* \
             /lib/systemd/system/sockets.target.wants/*initctl* \
             /lib/systemd/system/basic.target.wants/* \
             /usr/lib/tmpfiles.d/systemd-nologin.conf \
    && systemctl enable ssh

# The user Ansible connects as. Public key is mounted at runtime (see docker-compose.yml).
RUN useradd -m -s /bin/bash "$SSH_USER" \
    && echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"$SSH_USER" \
    && chmod 440 /etc/sudoers.d/"$SSH_USER" \
    && mkdir -p /home/"$SSH_USER"/.ssh \
    && chmod 700 /home/"$SSH_USER"/.ssh \
    && chown -R "$SSH_USER":"$SSH_USER" /home/"$SSH_USER"/.ssh \
    && mkdir -p /run/sshd

EXPOSE 22 80
STOPSIGNAL SIGRTMIN+3
CMD ["/lib/systemd/systemd"]
