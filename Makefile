# Include variable file from infra folder
include infra/var.mk 

# SSH Keys Directory for ec2 instances
KEYS="./keys/everischallenge"

# Name of Master/Worker nodes
MASTERNAME=Everis-master
WORKERNAME=Everis-worker

# Create resources from Infra folder
up: 
	@echo Creating resources via Terraform...
	cd ./infra && terraform apply --auto-approve

# SSH into the Worker ec2
ssh-worker:
	$(eval IP := $(shell aws ec2 describe-instances --output text --region $(REGION) --filters Name=tag:Name,Values=Everis-worker --query "Reservations[*].Instances[*].PublicIpAddress"))
	@ssh -i $(KEYS) ubuntu@$(IP)

# SSH into the Master EC2
ssh-master:
	$(eval IP := $(shell aws ec2 describe-instances --output text --region $(REGION) --filters Name=tag:Name,Values=Everis-master --query "Reservations[*].Instances[*].PublicIpAddress"))
	@ssh -i $(KEYS) ubuntu@$(IP)

halt:
	@echo Stopping Nodes...
	$(eval MASTERINSTANCEID := $(shell aws ec2 describe-instances --output text --region $(REGION) --filters Name=tag:Name,Values=Everis-master --query "Reservations[*].Instances[*].InstanceId"))
	$(eval WORKERINSTANCEID := $(shell aws ec2 describe-instances --output text --region $(REGION) --filters Name=tag:Name,Values=Everis-worker --query "Reservations[*].Instances[*].InstanceId"))
	@aws ec2 stop-instances --instance-ids $(MASTERINSTANCEID) $(WORKERINSTANCEID) --region $(REGION) 

start:
	@echo Starting Nodes...
	$(eval MASTERINSTANCEID := $(shell aws ec2 describe-instances --output text --region $(REGION) --filters Name=tag:Name,Values=Everis-master --query "Reservations[*].Instances[*].InstanceId"))
	$(eval WORKERINSTANCEID := $(shell aws ec2 describe-instances --output text --region $(REGION) --filters Name=tag:Name,Values=Everis-worker --query "Reservations[*].Instances[*].InstanceId"))
	@aws ec2 start-instances --instance-ids $(MASTERINSTANCEID) $(WORKERINSTANCEID) --region $(REGION) 

help:
	@echo "----------------------"
	@echo " "
	@echo "   Make <command>"
	@echo " "
	@echo "----------------------"
	@echo " "
	@echo Commands - 
	@echo " "
	@echo up: Run terraform apply in the /infra folder to spin up relevant infrastructure
	@echo ssh-worker: SSH into the ec2 named "Everis-worker"
	@echo ssh-master: SSH into the ec2 named "Everis-master"
	@echo halt: Will stop the state of the ec2s if they are running 
	@echo start: Will start the ec2s if they are in a stop state
	@echo " "
