#!/bin/bash

# set exit on error
set -e

# disable sleep
echo "disabling sleep..."
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# copy wifi config
echo "copying wifi config..."
mkdir -p /lib/firmware/brcm
cp -f roles/wifi/files/brcmfmac4356-pcie.* /lib/firmware/brcm/ || true

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
  echo "waiting for apt to be available..."
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    sleep 1
  done
  
  apt-get update
  apt-get -y install software-properties-common python-software-properties
  add-apt-repository -y ppa:ansible/ansible
  apt-get update
  
  echo "waiting for apt to be available..."
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    sleep 1
  done
  
  apt-get -y install ansible unzip wget
fi

# update ansible code
echo "downloading latest ansible code..."
mkdir /tmp/ansible-gpdpocket
wget -O /tmp/ansible-gpdpocket/master.zip https://bitbucket.org/chrisaw/ansible-gpdpocket/get/master.zip
unzip -o /tmp/ansible-gpdpocket/master.zip -d /tmp/ansible-gpdpocket/
cd /tmp/ansible-gpdpocket/chrisaw-ansible*

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml -e "bootstrap=true"

# clean up
echo "cleaning up..."
rm -rf /tmp/ansible-gpdpocket

# enable sleep
echo "enabling sleep..."
systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target

# reboot
echo "starting reboot..."
reboot