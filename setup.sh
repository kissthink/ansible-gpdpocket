#!/bin/sh

# setup wifi
cp roles/wifi/files/brcmfmac4356-pcie.txt /lib/firmware/brcm/brcmfmac4356-pcie.txt
modprobe -r brcmfmac
modprobe brcmfmac

# prompt for wifi connection
echo "Please connect to a WiFi network, then press return to continue:"
read

# install ansible
apt-get update
apt-get -y install ansible

# run ansible scripts (without cowsay! :P)
ANSIBLE_NOCOWS=1 ansible-playbook main.yml