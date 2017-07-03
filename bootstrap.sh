#!/bin/sh

# setup wifi
echo "setting up wifi..."
if [ ! -f /lib/firmware/brcm/brcmfmac4356-pcie.txt ]; then
  cp roles/wifi/files/brcmfmac4356-pcie.txt /lib/firmware/brcm/brcmfmac4356-pcie.txt
  modprobe -r brcmfmac
  modprobe brcmfmac

  # prompt for wifi connection
  echo "Please connect to a WiFi network, then press return to continue:"
  read
fi

# wait for internet connection
echo "waiting for internet connection..."
while ! ping -c1 google.com &>/dev/null; do
  sleep 1
done

# install ansible
echo "installing essential packages..."
rm -f /var/lib/dpkg/lock
add-apt-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible unzip wget

# update ansible code
echo "downloading latest ansible code..."
mkdir /tmp/ansible-gpdpocket
wget -O /tmp/ansible-gpdpocket/master.zip https://bitbucket.org/chrisaw/ansible-gpdpocket/get/master.zip
unzip /tmp/ansible-gpdpocket/master.zip -d /tmp/ansible-gpdpocket/
cd /tmp/ansible-gpdpocket/chrisaw-ansible*

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml

# cleanup
echo "performing clean up..."
cd
rm -rf /tmp/ansible-gpdpocket