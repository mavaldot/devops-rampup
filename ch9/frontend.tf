resource "aws_security_group_rule" "sg_frontend_bastion_rule" {

    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-frontend-sg"].id
    source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "sg_frontend_alb_rule" {

    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-frontend-sg"].id
    source_security_group_id = aws_security_group.alb_sg.id
}


resource "aws_launch_template" "frontend" {
  name = "frt"
  image_id           = "ami-0f8e81a3da6e2510a"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.rsa_key.key_name

  user_data = base64encode( <<-EOF
    #!/bin/bash
    cd /home/ubuntu
    sudo apt update -y
    sudo apt install -y python2 git
    sudo apt install -y npm nodejs
    git clone https://github.com/bortizf/microservice-app-example
    cd microservice-app-example/frontend
    rm package-lock.json
    npm cache clean --force
    npm install >/home/ubuntu/install.log 2>&1
    npm run build >/home/ubuntu/build.log 2>&1
    PORT=8080 AUTH_API_ADDRESS=http://${aws_lb.alb.dns_name}:8000 TODOS_API_ADDRESS=http://${aws_lb.alb.dns_name}:8082 \
    ZIPKIN_URL=http://${aws_lb.alb.dns_name}:9411/api/v2/spans npm start 1>/home/ubuntu/log 2>/home/ubuntu/error.log
    EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2_sg["ec2-frontend-sg"].id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ec2-t2micro"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-80"
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