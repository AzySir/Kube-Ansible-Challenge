# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Generic config

# OS/Box
VAGRANT_BOX = 'ubuntu/xenial64'
# VM User — 'vagrant' by default
VM_USER = 'vagrant'


# Master config params
VM_NAME_MASTER = 'evlab-master'
MASTER_ADDRESS = '192.168.56.50' ########## PLEASE CHANGE ME AS NEEDED
MASTER_HOSTNAME = "evlab-master.everlab.local"

# Worker config params
VM_NAME_WORKER ='evlab-worker'
WORKER_ADDRESS = '192.168.56.100' ########## PLEASE CHANGE ME AS NEEDED
WORKER_HOSTNAME = "evlab-worker.everlab.local"


Vagrant.configure(2) do |config|

  # Configuration definitions for the "Master" kube VM
  config.vm.define "master" do |master|

    # Configure box type
    master.vm.box = VAGRANT_BOX
    master.vm.hostname = MASTER_HOSTNAME

    # Configure the Network
    master.vm.network "private_network", ip: MASTER_ADDRESS

    master.vm.provider "virtualbox" do |v|
      v.name = VM_NAME_MASTER
      v.memory = 2048
    end

    # Script provisioner for Master
    $masterFirstBoot = <<-SCRIPT
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    apt update && apt install software-properties-common --yes
    apt install ansible --yes
    systemctl restart networking
    fallocate -l 256M /swapfile
	  chmod 600 /swapfile
	  mkswap /swapfile
	  swapon /swapfile
	  echo '/swapfile none swap defaults 0 0' >> /etc/fstab
    SCRIPT

    master.vm.provision "shell", inline: $masterFirstBoot
  end


  # Configuration definitions for the "Worker" kube VM
  config.vm.define "worker" do |worker|
    # Configure box type
    worker.vm.box = VAGRANT_BOX
    worker.vm.hostname = WORKER_HOSTNAME

    # Configure the Network
    worker.vm.network "private_network", ip: WORKER_ADDRESS

    worker.vm.provider "virtualbox" do |v|
      v.name = VM_NAME_WORKER
      v.memory = 1024
      worker.vm.synced_folder ".", "/vagrant", disabled: true
    end

    # Script provisioner for worker
    $scriptworker = <<-SCRIPT
    ping -c 10 ${masteraddress}
    systemctl restart networking
    SCRIPT

    worker.vm.provision "shell", inline: $scriptworker, env: {"masteraddress" => MASTER_ADDRESS},
      run: "always"
  end
end
