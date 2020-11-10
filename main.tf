terraform {
 required_version = ">=0.12"
}

provider "aws" {
    region = var.aws_region
}

resource "aws_instance" "simple" {
    ami = lookup(var.aws_amis, var.aws_region)
    instance_type = "t2.micro"
    
    vpc_security_group_ids = [aws_security_group.simple.id]

    user_data = file("install_nginx_etc.sh")
    tags = {
        Name = "simple"
        built_by = "me"
    }
}

resource "aws_security_group" "simple" {
    name = "simple-sg"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}
