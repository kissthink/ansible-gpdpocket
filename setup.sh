#!/bin/sh

# copy to /root
echo "copying playbooks to /root/ansible-gpdpocket..."
if [ ! -d /root/ansible-gpdpocket ]; then
  mkdir -p /root/ansible-gpdpocket
  cp -ar * /root/ansible-gpdpocket/
fi

# ensure correct dir
echo "changing to on-disk directory..."
cd /root/ansible-gpdpocket

# setup wifi (if necessary)
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

# wait for apt to be available
echo "waiting for apt to be available..."
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
  sleep 1
done

# install ansible (if necessary)
echo "ensuring ansible is installed..."
if [ ! -f /usr/bin/ansible ]; then
  add-apt-repository -y ppa:ansible/ansible
  apt-get update
  apt-get -y install ansible
fi

# install git
echo "ensuring git is installed..."
if [ ! -f /usr/bin/git ]; then
  apt-get -y install git
fi

# update git repository
echo "updating git repo..."
if [ ! -d .git ]; then
  git init
  git remote add origin https://chrisaw@bitbucket.org/chrisaw/ansible-gpdpocket.git
else
  git remote set-url origin https://chrisaw@bitbucket.org/chrisaw/ansible-gpdpocket.git
fi
git fetch --all
git reset --hard origin/master

# run ansible scripts (without cowsay! :P)
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook main.yml

# reboot after ansible run
echo "rebooting system..."
reboot