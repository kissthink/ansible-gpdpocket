#!/bin/bash

# set exit on error
set -e

# disable sleep
echo "disabling sleep..."
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# set branch to download
if [ "$1" = "--dev" ]; then
  BRANCH="dev"
else
  BRANCH="master"
fi

# wait for internet connection
echo "waiting for internet connection..."
while ! ping -c1 google.com &>/dev/null; do
  sleep 1
done

# update ansible code
echo "downloading latest ansible code..."
mkdir /tmp/ansible-gpdpocket
wget -O /tmp/ansible-gpdpocket/master.zip https://bitbucket.org/chrisaw/ansible-gpdpocket/get/${BRANCH}.zip
unzip -o /tmp/ansible-gpdpocket/master.zip -d /tmp/ansible-gpdpocket/
cd /tmp/ansible-gpdpocket/chrisaw-ansible*

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml

# cleanup
echo "performing clean up..."
cd
rm -rf /tmp/ansible-gpdpocket

# enable sleep
echo "enabling sleep..."
systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target