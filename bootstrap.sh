#!/bin/sh

# determine distro
if [ -f /usr/bin/apt-get ]; then
  DISTRO="debian"
elif [ -f /usr/bin/pacman ]; then
  DISTRO="arch"
else
  echo ERROR: Distribution not supported
  exit 1
fi

# copy wifi config
echo "copying wifi config..."
if [ "$DISTRO" = "arch" ]; then
  cp -f roles/wifi/files/brcmfmac4356-pcie.txt /usr/lib/firmware/brcm/brcmfmac4356-pcie.txt
elif [ "$DISTRO" = "debian" ]; then
  cp -f roles/wifi/files/brcmfmac4356-pcie.txt /lib/firmware/brcm/brcmfmac4356-pcie.txt
fi

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
if [ "$DISTRO" = "arch" ]; then
  pacman -Sy --noconfirm ansible unzip wget
elif [ "$DISTRO" = "debian" ]; then
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
unzip /tmp/ansible-gpdpocket/master.zip -d /tmp/ansible-gpdpocket/
cd /tmp/ansible-gpdpocket/chrisaw-ansible*

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml -e "bootstrap=true"

# cleanup
echo "performing clean up..."
cd
rm -rf /tmp/ansible-gpdpocket