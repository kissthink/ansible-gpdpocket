#!/bin/bash

# set exit on error
set -e

# wait for internet connection
echo "waiting for internet connection..."
while ! ping -c1 google.com &>/dev/null; do
  sleep 1
done

# wait for apt availability
echo "waiting for apt to be available..."
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
  sleep 1
done

# update ansible code
echo "downloading latest ansible code..."
if [ -d /usr/src/ansible-gpdpocket ]; then
  cd /usr/src/ansible-gpdpocket
  git pull -f
else
  git clone https://github.com/cawilliamson/ansible-gpdpocket.git /usr/src/ansible-gpdpocket
  cd /usr/src/ansible-gpdpocket
fi

# ensure /boot is mounted
mount /boot || true

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml