## Purpose
The code in this repo uses Terraform to deploy a nginx webserver on an Ubuntu instance behind a load balancer with an autoscaling group in AWS.

## Variables:

### aws_region
AWS region is set with the aws_region variable, current options available us-east-1, us-west-2, ca-central-1


### aws_vpc_identifier, aws_subnet_1, aws_subnet_2
VPC and subnets should be set up in advance and can be specified with aws_vpc_identifier, aws_subnet_1 and aws_subnet_2 respectively
Not currently available but can be added is option for third subnet


### aws_amis
Defaults to map of AMIs to regions for latest Ubuntu 18.04 AMI for ca-central-1, us-east-1 and us-west-2


## Assumptions:

Access to AWS is set up and user has full access to EC2, S3
Terraform state stored in S3 bucket, bucket name key and region are hardcoded and need to be replaced before running
VPC and subnets set up in advance and are not created by Terraform

## Run:

`terraform apply -var="aws_region=$aws_region" -var="aws_vpc_identifier=$vpc_id" -var="aws_subnet_1=$aws_subnet_1" -var="aws_subnet_2=$aws_subnet_2"`