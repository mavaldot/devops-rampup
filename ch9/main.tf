terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    bucket = "ramp-up-devops-psl"
    key = "mateo.valdeso/terraform.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region     = "us-west-1"
}

resource "aws_key_pair" "rsa_key" {
  key_name   = "rsa_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  description = "Security group for the alb"
  vpc_id = var.my_vpc

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9001
    to_port = 9001
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8082
    to_port = 8082
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8083
    to_port = 8083
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9411
    to_port = 9411
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8000
    to_port = 8000
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

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets = [var.public_subnet_1, var.public_subnet_2]
  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    project = var.project
    responsible = var.responsible
  }

}

resource "aws_lb_listener" "listener_8080" {
  load_balancer_arn = aws_lb.alb.arn
  port = "8080"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.frontend_group.arn
  }

}

resource "aws_lb_listener_rule" "path_routing_login" {
  listener_arn = aws_lb_listener.listener_8080.arn
  priority = 1

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.auth_group.arn
  }

  condition {
    path_pattern {
      values = ["*/login"]
    }
  }
}

resource "aws_lb_listener_rule" "path_routing_todos" {
  listener_arn = aws_lb_listener.listener_8080.arn
  priority = 2

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.todos_group.arn
  }

  condition {
    path_pattern {
      values = ["*/todos*"]
    }
  }
}

resource "aws_lb_target_group" "frontend_group" {
  name = "alb-frontend-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = var.my_vpc
}

resource "aws_autoscaling_attachment" "frontend_attachment" {
  autoscaling_group_name = aws_autoscaling_group.frontend.id
  alb_target_group_arn = aws_lb_target_group.frontend_group.arn
}

resource "aws_lb_listener" "listener_8000" {
  load_balancer_arn = aws_lb.alb.arn
  port = "8000"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.auth_group.arn
  }

}

resource "aws_lb_target_group" "auth_group" {
  name = "alb-auth-group"
  port = 8000
  protocol = "HTTP"
  vpc_id = var.my_vpc
}

resource "aws_autoscaling_attachment" "auth_attachment" {
  autoscaling_group_name = aws_autoscaling_group.auth.id
  alb_target_group_arn = aws_lb_target_group.auth_group.arn
}

resource "aws_lb_listener" "listener_8082" {
  load_balancer_arn = aws_lb.alb.arn
  port = "8082"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.todos_group.arn
  }

}

resource "aws_lb_target_group" "todos_group" {
  name = "alb-todos-group"
  port = 8082
  protocol = "HTTP"
  vpc_id = var.my_vpc
}

resource "aws_autoscaling_attachment" "todos_attachment" {
  autoscaling_group_name = aws_autoscaling_group.todos.id
  alb_target_group_arn = aws_lb_target_group.todos_group.arn
}

resource "aws_lb_listener" "listener_8083" {
  load_balancer_arn = aws_lb.alb.arn
  port = "8083"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.users_group.arn
  }

}

resource "aws_lb_target_group" "users_group" {
  name = "alb-users-group"
  port = 8083
  protocol = "HTTP"

  health_check {
    enabled = true
    matcher = "200-499"
  }

  vpc_id = var.my_vpc
}

resource "aws_autoscaling_attachment" "users_attachment" {
  autoscaling_group_name = aws_autoscaling_group.users.id
  alb_target_group_arn = aws_lb_target_group.users_group.arn
}

resource "aws_lb_listener" "listener_9001" {
  load_balancer_arn = aws_lb.alb.arn
  port = "9001"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lmp_group.arn
  }

}

resource "aws_lb_target_group" "lmp_group" {
  name = "alb-lmp-group"
  port = 9001
  protocol = "HTTP"
  vpc_id = var.my_vpc
}

resource "aws_autoscaling_attachment" "lmp_attachment" {
  autoscaling_group_name = aws_autoscaling_group.lmp.id
  alb_target_group_arn = aws_lb_target_group.lmp_group.arn
}

resource "aws_lb_listener" "listener_9411" {
  load_balancer_arn = aws_lb.alb.arn
  port = "9411"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.zipkin_group.arn
  }

}

resource "aws_lb_target_group" "zipkin_group" {
  name = "alb-zipkin-group"
  port = 9411
  protocol = "HTTP"
  vpc_id = var.my_vpc
}

resource "aws_autoscaling_attachment" "zipkin_attachment" {
  autoscaling_group_name = aws_autoscaling_group.zipkin.id
  alb_target_group_arn = aws_lb_target_group.zipkin_group.arn
}