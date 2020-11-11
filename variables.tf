variable "aws_region" {
    description = "AWS region in which to launch services"
    default = "ca-central-1"
}

variable "aws_amis" {
    type = map(string)
    default = {
        # Ubuntu Offical AMIs      
        ca-central-1 = "ami-0e625dfca3e5a33bd"
        us-west-2 = "ami-089f171a1ba090f7c"
        us-east-1 = "ami-074db80f0dc9b5f40"
    }
}

variable "aws_vpc_identifier" {
    default = "vpc-af3b1fc7"
}

variable "aws_subnet_1" {
    default = "subnet-95b2f8fd"
}

variable "aws_subnet_2" {
    default = "subnet-c01076ba"
}