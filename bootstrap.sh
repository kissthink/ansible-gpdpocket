#!/bin/bash

# set exit on error
set -e

# copy wifi config
echo "copying wifi config..."
mkdir -p /lib/firmware/brcm
cp -f roles/wifi/files/brcmfmac4356-pcie.* /lib/firmware/brcm/

# enable wifi
echo "enabling wifi..."
modprobe -r brcmfmac
modprobe brcmfmac

# prompt for wifi connection
echo "Please connect to a WiFi network, then press return to continue:"
read

# wait for internet connection
echo "waiting for internet connection..."
while ! ping -c1 google.com &>/dev/null; do
  sleep 1
done

# install ansible
echo "installing essential packages..."
if [ -f /usr/bin/pacman ]; then
  pacman -Sy --noconfirm ansible unzip wget
elif [ -f /usr/bin/apt-get ]; then
  # wait for apt availability
  echo "waiting for apt to be available..."
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    sleep 1
  done
  
  apt-get update
  apt-get -y install software-properties-common python-software-properties
  add-apt-repository -y ppa:ansible/ansible
  apt-get update
  apt-get -y install ansible git unzip
fi

# update ansible code
echo "downloading latest ansible code..."
git clone https://github.com/cawilliamson/ansible-gpdpocket.git /usr/src/ansible-gpdpocket
cd /usr/src/ansible-gpdpocket 

# ensure /boot is mounted
mount /boot || true

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml

# reboot
echo "starting reboot..."
reboot