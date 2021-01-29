# Everis Code Challenge

---

## Scope of this directory
The reason this directory was created and added to the whole repo is due to the fact that I have an Apple M1 silicon and the arm64 architecture was not friendly with any virtualisation services especially VirtualBox.

As a result I decided to create 2 ECs instances, with Elastic IPs inside of a public subnet containing a route table leading to the internet gateway

---

## How to use
The infrastructure for this repository has been built using Terraform. For simplicity the Terraform is ran via a makefile

--

## Makefile

To run please write `Make <command>`

 
## Pre-requisite

**create-state**
create-state fulfils the pre-requisites required for a Terraform setup. This includes creating the following 
 
 * S3 Backend Bucket (aws cli)
 * aws cli command to lock down the bucket by setting publicly accessibility off 
 * Creating DynamoDB Locktable with LockID as Primary Key

3 stages involved in this command include create-bucket, lockdown-bucket, create-table

---

**Usage**

**init**
After the pre-requisite of `make create-state` has been executed please continue on to initialising the terraform directory. This will dynamically add a key, bucketname, region and locktable depending on the variables that are located inside of the var.mk

**make apply**
This will run the following terraform command and create the infrastructure

```
    terraform apply --auto-approve
```

**make destroy**
This will run the following terraform command and destroy the infrastructure

```
    terraform destroy --auto-approve
```


**make plan**
This will run the following terraform command and plan for the infrastructure creation

```
    terraform plan
```
