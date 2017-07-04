#!/bin/sh

# determine distro
if [ -f /usr/bin/apt-get ]
  DISTRO="debian"
elif [ -f /usr/bin/pacman ]
  DISTRO="arch"
else
  echo ERROR: Distribution not supported
  exit 1
fi

# setup wifi
echo "setting up wifi..."
if [ "$DISTRO" = "arch" ]; then
  FIRMWARE_PREFIX='/usr'
fi

if [ ! -f ${FIRMWARE_PREFIX}/lib/firmware/brcm/brcmfmac4356-pcie.txt ]; then
  cp roles/wifi/files/brcmfmac4356-pcie.txt ${FIRMWARE_PREFIX}/lib/firmware/brcm/brcmfmac4356-pcie.txt
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
if [ "$DISTRO" = "debian" ]; then
  rm -f /var/lib/dpkg/lock
  apt-get update
  apt-get -y install software-properties-common python-software-properties
  add-apt-repository -y ppa:ansible/ansible
  apt-get update
  apt-get -y install ansible unzip wget
elif [ "$DISTRO" = "arch" ]; then
  pacman -Sy --noconfirm ansible unzip wget
fi

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