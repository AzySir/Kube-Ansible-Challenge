# Notes

## Pre-Requisites 

Set this environment variable ANSIBLE_HOST_KEY_CHECKING=false so that you dont' get prompted for fingerprints when sshing via ansible


## IMPORTANT ARCHITECTUAL INFO
Due to the fact that I had to use an Apple M1 Silicon I faced issues with virtualisation since I have an arm64 architecture. This meant that the VirtualBox set up provided via Vagrant would not work
accordingly. Unfortunately I have no access to any other devices. 

As a result I have used 2 AWS EC2 instances created via terraform including a public subnet, internet gateway, and elastic IPs. The EC2s have user-data to mirror the vagrant start ups.


## Notes for solution

1. I was not able to use Vagrant or VMs due to the fact that I have a Mac OSX M1 Silicon. VirtualBox does not support an ARM64 architecture

2. So I decided to create the master/worker as an ec2 instance along with user data for installation. 

3. I created both of these via Terraform located in the /infra folder. Please follow the readme in that folder for more information. The user deploy was created via Terraform in the user data (see conclusion notes for more info). 

**The /Infra folder has everything INFRASTRUCTURE specific - please see for more info**

4. Added the below variables into the hosts inventory.ini

`apt_key="https://packages.cloud.google.com/apt/doc/apt-key.gpg" repo="deb http://apt.kubernetes.io/ kubernetes-xenial main"`

And referenced them in the playbook as so - 

```
url: "{{ hostvars.master1.apt_key }}"
repo: "{{ hostvars.worker1.repo }}"
```


5. Ran the command -

`ansible-playbook kube-repos.yml -i inventory.ini --private-key ../keys/everischallenge`

6. Ran the ansible playbook. It seems that the steps that did not work included (below). 

`ansible-playbook kube-deps.yml -i inventory.ini --private-key ../keys/everischallenge`

* To debug this I SSHed into the master node and realised that the kubeadm did not init properly 
due to hardware constraints of the ec2. 

* As a result I upgraded the sizes of the ec2 to run this again

* The EC2 Public IPs did not need to change due to an EIP attached to both. As a result the Public IPs remained the same.

* I proceeded to run the ansible steps from 1-5 again and it worked as expected

-  - name: initialize the cluster
      shell: kubeadm init --pod-network-cidr=10.99.0.0/16 >> cluster_init.txt
      args:
        chdir: $HOME
        creates: cluster_init.txt

    - name: create .kube directory
      become: yes
      become_user: kube
      file:
        path: $HOME/.kube
        state: directory
        mode: 0755

7. 
* Command Ran: ansible-playbook kube-master.yml -i inventory.ini --private-key ../keys/everischallenge 

* It seems that the stage below failed. When I went to investigate and run these commands manually I realised there was a "not root user" error thrown.

* As a result I ran the following commands to make the setup at 0 again.
  * kubeadm reset
  * systemctl restart kubelet

* Then I ran the below -
  * sudo su
  * kubeadm init --pod-network-cidr=10.99.0.0/16 

    - name: copy admin.conf to user's kube config
      copy:
        src: /etc/kubernetes/admin.conf
        dest: /home/kube/.kube/config
        remote_src: yes
        owner: kube
      become: true

  8.
  * To verify the pods are working on the Master I checked the pod_network_setup.txt first according to the playbook. I could see that something had been installed
  * Then I tried kubectl get pods and received this error "No resources found in default namespace"
  * So I ran `kubectl get namespace` which returned -

      ```
      NAME              STATUS   AGE
      default           Active   10m
      kube-node-lease   Active   10m
      kube-public       Active   10m
      kube-system       Active   10m
      ```
  * Then I ran `kubectl get pods --all-namespaces` to confirm pods were working and received - 

      ```
      NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
      kube-system   calico-kube-controllers-6dfcd885bf-r2h6t   1/1     Running   0          10m
      kube-system   calico-node-gtjj8                          1/1     Running   0          10m
      kube-system   coredns-74ff55c5b-69b2q                    1/1     Running   0          10m
      kube-system   coredns-74ff55c5b-gpddk                    1/1     Running   0          10m
      kube-system   etcd-ip-10-0-0-135                         1/1     Running   0          11m
      kube-system   kube-apiserver-ip-10-0-0-135               1/1     Running   0          11m
      kube-system   kube-controller-manager-ip-10-0-0-135      1/1     Running   0          11m
      kube-system   kube-proxy-45pvb                           1/1     Running   0          10m
      kube-system   kube-scheduler-ip-10-0-0-135               1/1     Running   0          11m 
      ```
  
  9. Ran the following command: ansible-playbook kube-workers.yml -i inventory.ini --private-key ../keys/everischallenge
    * Recevied this error - "skipping: no hosts matched" for the step in the playbook below 
      ```
      - hosts: workers
    become: yes
    tasks:

      - name: join cluster
        shell: "{{ hostvars['master'].join_command }} >> node_join.txt"
        args:
          chdir: $HOME
          creates: node_join.txt
      ```
  10. To see that the worker pod was running I ran the following command from master
  * kube@ip-10-0-0-135:~$ kubectl get pods -o wide
  * The IP 10.0.0.35 is the ec2 instance of the worker
  * 10.99.0.0/16 is the ip address that was used when the kubeadm init command was run via ansible. 
    As you can see the calico nodes are there I'm not sure if this is expected I believe it is. 

    ```
    NAME                                       READY   STATUS    RESTARTS   AGE     IP            NODE            NOMINATED NODE   READINESS GATES
    calico-kube-controllers-6dfcd885bf-r2h6t   1/1     Running   0          3h42m   10.99.208.3   ip-10-0-0-135   <none>           <none>
    calico-node-f2sw9                          1/1     Running   0          25m     10.0.0.35     ip-10-0-0-35    <none>           <none>
    calico-node-gtjj8                          1/1     Running   0          3h42m   10.0.0.135    ip-10-0-0-135   <none>           <none>
    coredns-74ff55c5b-69b2q                    1/1     Running   0          3h42m   10.99.208.2   ip-10-0-0-135   <none>           <none>
    coredns-74ff55c5b-gpddk                    1/1     Running   0          3h42m   10.99.208.1   ip-10-0-0-135   <none>           <none>
    etcd-ip-10-0-0-135                         1/1     Running   0          3h43m   10.0.0.135    ip-10-0-0-135   <none>           <none>
    kube-apiserver-ip-10-0-0-135               1/1     Running   0          3h43m   10.0.0.135    ip-10-0-0-135   <none>           <none>
    kube-controller-manager-ip-10-0-0-135      1/1     Running   0          3h43m   10.0.0.135    ip-10-0-0-135   <none>           <none>
    kube-proxy-2vp2f                           1/1     Running   0          25m     10.0.0.35     ip-10-0-0-35    <none>           <none>
    kube-proxy-45pvb                           1/1     Running   0          3h42m   10.0.0.135    ip-10-0-0-135   <none>           <none>
    kube-scheduler-ip-10-0-0-135               1/1     Running   0          3h43m   10.0.0.135    ip-10-0-0-135   <none>           <none>
    ```


## Conclusion Notes 
* Mistaking noticed I hadn't used the "deploy" group - so I went ahead and created that via ec2-user data and ran through all the steps again (from Step3)

---  

# Everis Technical Exercise

A technical exercise using Ubuntu and ansible to configure a basic kubernetes cluster consisting of a single master and single worker node using the popular kubeadm for bootstrapping. It's not expected or required to have any specific Kubernetes experience to be able to complete the tasks in this exercise. This is a typical example of a cluster setup that someone may use as their own lab environment.

## Setup

This exercise utilises Vagrant for the lab environment setup. Vagrant allows for the build and creation of virtual environments that are defined as configuration parameters in a "VagrantFile" and as a result, are reproducible and portable. More information on Vagrant can be found at the link below. 

### Pre-requisites

* VirtualBox - (https://www.virtualbox.org/wiki/Downloads)
* Vagrant - (https://www.vagrantup.com/)
* Git - (https://git-scm.com/downloads)

...and a machine to run all of the above that has internet connectivity. 

This exercise has been tested with the following setups:

---
* Windows 10 Enterprise Host
* VirtualBox Version 5.2.22 r126460
* Vagrant Version 2.2.4
* Git version 2.19.1.windows.1
  
---
  
* macOS Mojave 10.14.6 Host
* VirtualBox Version 6.0.12 r133076 (Qt5.6.3)
* Vagrant Version 2.2.5
* Git version 2.23.0
---

  
This setup should in fact work fine on Linux or other versions of Mac and Windows too, but hasn't been tested by us. If you're confident it will work, feel free to give it a try on a platform of your choosing. 

### Networking

The VagrantFile included in this repository will create 2x Virtual Machines. One named "Master" and one named "Worker". The communication between these machines relies on the presence of a "Host-Only" network adapter that is installed by default with VirtualBox. This adapter acts as a "private" network that allows communication between guest Virtual Machines and the host. This will be the basis for communication between nodes in our Kubernetes cluster. All communication between master and worker nodes will occur via this Host-Only virtual network.

To find out the specific details of the Host-Only adapter on your system, run the following: 

```
#> C:\Program Files\Oracle\VirtualBox\VBoxManage.exe list hostonlyifs

Name:            VirtualBox Host-Only Ethernet Adapter
GUID:            49d645a0-e5b7-4589-bfe0-2126b15890c9
DHCP:            Disabled
IPAddress:       192.168.56.1
NetworkMask:     255.255.255.0
IPV6Address:
IPV6NetworkMaskPrefixLength: 0
HardwareAddress: 0a:00:27:00:00:09
MediumType:      Ethernet
Wireless:        No
Status:          Up
VBoxNetworkName: HostInterfaceNetworking-VirtualBox Host-Only Ethernet Adapter
```

Each Virtual Machine will also have a single NAT interface but this can largely be ignored as it's only used for pulling packages from the Internet. 

### Steps

* Download the pre-requisites listed above. 
* Gather the information relating to your host-only adapter
* Fork this repository. Name your new forked repository as follows:

tech-lab-[Firstname]-[lastname]

So, if my name was John Smith, my new forked repository would look like

"tech-lab-john-smith"

From this point you can treat this like any typical repository you own! Clone this repository to your local machine and create a branch to work from:

```
#> git clone https://johnsmith@bitbucket.org/johnsmith/tech-lab-john-smith.git
#> cd tech-lab-john-smith/
#> git checkout -b "john-smiths-test-attempt"
```

* Ensure you are inside the cloned repo directory! Edit the VagrantFile. Replace the variables below as appropriate so that they fall within the subnet of your host-only network. This will depend on the addressing of your host-only adapter. For example, looking at the adapter setting above, we can see the addressing is 192.168.56.1 and the subnet mask is 255.255.255.0. This means the addresses used for the Worker and the Master must fall between 192.168.56.2 and  192.168.56.254. For example:

```
MASTER_ADDRESS = '192.168.56.50'
WORKER_ADDRESS = '192.168.56.100'
```
* Run the command:

```
#> vagrant up
```
...to begin box provisioning. Once the provisioning is complete, login to the nodes using vagrant ssh: 

```
#> vagrant ssh worker
```
```
#> vagrant ssh master
```

If at any time you wish to power down the boxes but retain the changes you've made so far, run: 
```
#> vagrant halt
```

If at any time you wish to destroy the boxes and recreate them in their default states, run:
```
#> vagrant destroy
```
```
#> vagrant up
```

Now on to the fun part!

# Tasks


#### Please keep some notes as you progress through the tasks below with thoughts, solutions etc... These can contain whatever you like but should generally cover what you changed and why. These notes will be submitted at the end of the exercise.
  
  
  
 1) We're going to be using Ansible to deploy some configuration on the Master and Worker nodes. To help with this, we'll create a deployment user. Do the following: 

* Create a user called "deploy" on both the master and worker nodes
* Make sure this user account is secure (within **reason**)
* Bear in mind this is for deployment tasks and configure the user privileges appropriately
  
---

 2) Navigate to ```/vagrant/ansible```. This directory contains a number of ```.yml``` files for use with ansible. 

---

 3) Create and populate an ansible inventory file in ```/vagrant/ansible``` so that it has:

* A host group called "masters" that contains a single host called "master1"
* A host group called "workers" that contains a single host called "worker1"
* Configure both hosts to use the "deploy" user you created earlier

---

 4) Look at the ```kube-repos.yml``` file. Replace the hardcoded Kubernetes apt-key URL so that it can be defined per-host. Please use a suitable variable name. 

---

 5) Apply the ```kube-repos.yml```

---

 6) Apply the ```kube-deps.yml``` playbook. The play will fail, fix the errors and apply again! 

---

 7) Apply the playbook ```kube-master.yml```. Fix any errors that occur and apply it again. Ensure any changes you make manually are also included in the ```kube-master.yml``` playbook so this issue doesn't arise again.

---

 8) Verify that the master node is functioning correctly on its own. If it isn't, fix any issues. A good way to test this may be to list out all the system pods in a "running" state. Include this in your notes. 
 
---

 9) Run the ```kube-workers.yml``` playbook. Fix any issues that arise during the cluster join. It might be nice to amend the playbooks with any fixes you make. 

---

 10) Run a few basic commands to check that the cluster is configured, showing pods running and nodes ready. Include the output in your notes. 

  
# Submitting results

To submit your results: 

* Add, commit and then push any changes you have made in your branch.
* Add us as a collaborator on your forked repo, read-only access is fine. 

At a minumum, please include the following in your submitted branch: 

* Ansible inventory
* Ansible playbooks with any changes
* Notes file, detailing your approach to the tasks and any changes made


Don't forget to let us know you've finished :) 