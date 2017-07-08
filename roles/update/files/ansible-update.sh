#!/bin/sh

# update ansible code
echo "downloading latest ansible code..."
mkdir /tmp/ansible-gpdpocket
wget -O /tmp/ansible-gpdpocket/master.zip https://bitbucket.org/chrisaw/ansible-gpdpocket/get/master.zip
unzip -o /tmp/ansible-gpdpocket/master.zip -d /tmp/ansible-gpdpocket/
cd /tmp/ansible-gpdpocket/chrisaw-ansible*

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml

# cleanup
echo "performing clean up..."
cd
rm -rf /tmp/ansible-gpdpocket