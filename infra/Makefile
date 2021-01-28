include var.mk

.PHONY: all

# Creates the State Bucket AND DynamoDB Lock Table
create-state: create-bucket lockdown-bucket create-table
	

# Create S3 Bucket for Statefile
create-bucket:
	@aws s3api create-bucket --bucket $(BUCKETNAME) \
	--region $(REGION) \
	--create-bucket-configuration LocationConstraint=$(REGION)
	@aws s3api put-object --bucket $(BUCKETNAME) --key $(KEY)/ --region $(REGION)

# Lock Down Bucket From Public
lockdown-bucket:
	@aws s3api put-public-access-block \
    --bucket $(BUCKETNAME) \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
	--region $(REGION)

#Create Dynamo DB for locking
create-table:
	@aws dynamodb create-table \
    --table-name $(LOCKTABLE) \
	--key-schema AttributeName=LockID,KeyType=HASH \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
	--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
	--region $(REGION)

apply:
	terraform apply --auto-approve

destroy:
	terraform destroy

plan:
	terraform plan

init: 
	terraform init -backend-config="key=$(KEY)" \
	-backend-config="region=$(REGION)" \
	-backend-config=bucket=$(BUCKETNAME) \
	-backend-config=dynamodb_table=$(LOCKTABLE) 

