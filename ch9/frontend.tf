resource "aws_security_group" "frontend_sg" {
  name = "frontend-sg"
  description = "Security group for the frontend ec2"
  vpc_id = var.my_vpc

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_launch_template" "frontend" {
  name_prefix   = "frontend-"
  image_id           = "ami-0f34c5ae932e6f0e4"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.rsa_key.key_name

  user_data = base64encode( <<-EOF
    #!/bin/bash
    cd ~
    echo "asdf" > mateo
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --rm -dp 80:80 -e PORT=80 -e AUTH_API_ADDRESS=${aws_lb.alb.dns_name}:8000 -e TODOS_API_ADDRESS=${aws_lb.alb.dns_name}:8082 mvot/frontend-app:first
    EOF
  )

  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "frontend" {
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1

  launch_template {
    id = aws_launch_template.frontend.id
    version = "$Latest"
  }

  vpc_zone_identifier = [var.private_subnet_1, var.private_subnet_2]

  tag {
    key = "project"
    value = var.project
    propagate_at_launch = true
  }

  tag {
    key = "responsible"
    value = var.responsible
    propagate_at_launch = true
  }
}