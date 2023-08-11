provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_key_pair" "rsa_key" {
  key_name   = "rsa_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets = [var.public_subnet_1, var.public_subnet_2]
  tags = {
    project = var.project
    responsible = var.responsible
  }

}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.frontend_group.arn
  }

}

resource "aws_lb_target_group" "frontend_group" {
  name = "alb-frontend-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.my_vpc
}

resource "aws_autoscaling_attachment" "frontend_attachment" {
  autoscaling_group_name = aws_autoscaling_group.frontend.id
  lb_target_group_arn = aws_lb_target_group.frontend_group.arn
}