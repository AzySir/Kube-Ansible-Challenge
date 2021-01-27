# !/bin/bash
sudo apt-add-repository --yes --update ppa:ansible/ansible
apt update && apt install software-properties-common --yes
apt install ansible --yes
systemctl restart networking
fallocate -l 256M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab
createuser deploy