terraform {
    required_version = ">=0.12"
    backend "s3" {
        bucket = "walshhslaw-terraform-store"
        key = "terraform-fun"
        region = "ca-central-1"
    }
}

provider "aws" {
    region = var.aws_region
}

data "aws_subnet" "selected_1" {
    id = var.aws_subnet_1
}

data "aws_subnet" "selected_2" {
    id = var.aws_subnet_2
}

resource "aws_launch_configuration" "simple_inst" {
    image_id = lookup(var.aws_amis, var.aws_region)
    instance_type = "t2.micro"
    security_groups = [aws_security_group.simple.id]
    user_data = file("install_nginx_etc.sh")
    lifecycle {
        create_before_destroy = true
    }
    name = "simple_inst_config"
}

resource "aws_autoscaling_group" "simple_insts" {
    launch_configuration = aws_launch_configuration.simple_inst.id
    target_group_arns = [aws_lb_target_group.simple_group.arn]
    availability_zones = [data.aws_subnet.selected_1.availability_zone, data.aws_subnet.selected_2.availability_zone]
    name = "simple-insts-group"
    health_check_type = "ELB"
    min_size = 1
    max_size = 3
    tag {
        key = "Name"
        value = "simple_inst"
        propagate_at_launch = true
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

resource "aws_autoscaling_policy" "simple" {
    name = "simple-policy"
    autoscaling_group_name = aws_autoscaling_group.simple_insts.name
    policy_type = "TargetTrackingScaling"
    adjustment_type = "ChangeInCapacity"
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
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

output "alb_domain_name" {
    value = aws_lb.simple_gate.dns_name
    description = "LB domain"
}
