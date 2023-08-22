resource "aws_security_group_rule" "sg_auth_bastion_rule" {

    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-auth-sg"].id
    source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "sg_auth_alb_rule" {

    type = "ingress"
    from_port = 8000
    to_port = 8000
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-auth-sg"].id
    source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_launch_template" "auth" {
  name_prefix   = "auth-"
  image_id           = "ami-0f8e81a3da6e2510a"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.rsa_key.key_name

  user_data = base64encode( <<-EOF
    #!/bin/bash
    cd /home/ubuntu
    sudo apt update -y
    sudo apt install -y git
    sudo apt install -y golang
    git clone https://github.com/bortizf/microservice-app-example.git
    cd /home/ubuntu/microservice-app-example/auth-api
    sudo go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api 
    sudo go mod tidy
    sudo go build > /home/ubuntu/build-log 2>&1
    AUTH_API_PORT=8000 USERS_API_ADDRESS=http://${aws_lb.alb.dns_name}:8083 JWT_SECRET=PRFT ./auth-api 1>/home/ubuntu/log 2>/home/ubuntu/error.log
    EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2_sg["ec2-auth-sg"].id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ec2-t2micro"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
        name = "ec2-8000"
      project = var.project
      responsible = var.responsible
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      project = var.project
      responsible = var.responsible
    }
  }
}

resource "aws_autoscaling_group" "auth" {
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1

  launch_template {
    id = aws_launch_template.auth.id
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