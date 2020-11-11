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
    }
}

resource "aws_security_group" "simple" {
    name = "simple-sg"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.simple_gate_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "simple_gate" {
    
    name = "simple-gateway"

    security_groups = [aws_security_group.simple_gate_sg.id]
    internal = false
    load_balancer_type = "application"
    subnets = [var.aws_subnet_1, var.aws_subnet_2]
}


resource "aws_security_group" "simple_gate_sg" {
    
    name = "simple-lb-sg"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "simple_gate_listener_sg" {
    
    name = "simple-lb-list-sg"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.simple_gate_sg.id]
  }
}
resource "aws_lb_listener" "simple_gate_listener" {  
    load_balancer_arn = aws_lb.simple_gate.arn
    port = "80"  
    protocol = "HTTP"

    default_action {    
        target_group_arn = aws_lb_target_group.simple_group.arn
        type = "forward"  
    }
}

resource "aws_lb_target_group" "simple_group" {
    name = "simple-group-lb-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.aws_vpc_identifier

    health_check {
        path = "/health.html"
        interval = 60
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group_attachment" "simple_group_attach" {
    target_group_arn = aws_lb_target_group.simple_group.arn
    target_id = aws_instance.simple.id
    port = 80
}

output "alb_domain_name" {
  value = aws_lb.simple_gate.dns_name
  description = "LB domain"
}