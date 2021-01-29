#!/bin/bash

echo "Preparing Image"
sudo apt-add-repository --yes --update ppa:ansible/ansible
apt update && apt install software-properties-common --yes
apt install ansible --yes
systemctl restart networking
fallocate -l 256M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

#Add Deploy User
echo "Creating Deploy User..."
adduser --disabled-password --gecos "" deploy 
su - deploy -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh'
su - deploy -c 'touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
su - deploy -c "echo ${ssh_key} >> ~/.ssh/authorized_keys"

echo "Adding Deploy to sudo group"
usermod -aG sudo deploy
echo '%deploy ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

swapoff -a