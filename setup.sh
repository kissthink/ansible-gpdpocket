#!/bin/sh

# setup wifi (if necessary)
if [ ! -f /lib/firmware/brcm/brcmfmac4356-pcie.txt ]; then
  cp roles/wifi/files/brcmfmac4356-pcie.txt /lib/firmware/brcm/brcmfmac4356-pcie.txt
  modprobe -r brcmfmac
  modprobe brcmfmac

  # prompt for wifi connection
  echo "Please connect to a WiFi network, then press return to continue:"
  read
fi

# wait for internet connection
while ! ping -c1 google.com &>/dev/null; do
  sleep 1
done

# wait for apt to be available
while [ -f /var/lib/dpkg/lock ]; do
  sleep 1
done

# install ansible (if necessary)
if [ ! -f /usr/bin/ansible ]; then
  add-apt-repository -y ppa:ansible/ansible
  apt-get update
  apt-get -y install ansible
fi

# install git
if [ ! -f /usr/bin/git ]; then
  apt-get -y install git
fi

# update git repository
if [ ! -d .git ]; then
  git init
  git remote add origin https://chrisaw@bitbucket.org/chrisaw/ansible-gpdpocket.git
else
  git remote set-url origin https://chrisaw@bitbucket.org/chrisaw/ansible-gpdpocket.git
fi
git fetch --all && git reset --hard origin/master

# run ansible scripts (without cowsay! :P)
ANSIBLE_NOCOWS=1 ansible-playbook main.yml

# reboot after ansible run
reboot