#!/bin/sh

# install all dependencies for ansible scripts to run
dpkg -i bootstrap/*.deb

# run ansible scripts
ANSIBLE_NOCOWS=1 ansible-playbook main.yml