#!/bin/bash

#Add Deploy User
echo "Creating Deploy User..."
adduser --disabled-password --gecos "" deploy 
su - deploy -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh'
su - deploy -c 'touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
su - deploy -c "echo ${ssh_key} >> ~/.ssh/authorized_keys"

#Ping Master
echo "Pinging master..."
ping -c 10 ${masteraddress}

echo "Restarting netowrking..."
systemctl restart networking

echo "Adding deploy to sudo group"
usermod -aG sudo deploy
echo '%deploy ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

swapoff -a