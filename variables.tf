variable "aws_region" {
    description = "AWS region in which to launch services"
    default = "ca-central-1"
}

variable "aws_profile" {
    description = "AWS credentials profile"
}

variable "aws_amis" {
    type = map(string)
    description = "AWS AMIs"
}

variable "aws_vpc_identifier" {
    description = "AWS VPC ID"
}

variable "aws_subnet_1" {
    description = "AWS subnet ID for load balancer: 1"
}

variable "aws_subnet_2" {
    description = "AWS subnet ID for load balancer: 2"
}
