resource "aws_security_group_rule" "sg_users_bastion_rule" {

    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-users-sg"].id
    source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "sg_users_alb_rule" {

    type = "ingress"
    from_port = 8083
    to_port = 8083
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-users-sg"].id
    source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_launch_template" "users" {
  name = "users"
  image_id           = "ami-0f8e81a3da6e2510a"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.rsa_key.key_name

  user_data = base64encode( <<-EOF
    #!/bin/bash
    cd /home/ubuntu
    sudo apt update -y
    sudo apt install openjdk-8-jdk git -y
    git clone https://github.com/bortizf/microservice-app-example.git
    cd microservice-app-example/users-api
    ./mvnw clean install >/home/ubuntu/build-log 2>&1 
    SERVER_PORT=8083 JWT_SECRET=PRFT java -jar target/users-api-0.0.1-SNAPSHOT.jar >/home/ubuntu/log 2>/home/ubuntu/error.log 
    EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2_sg["ec2-users-sg"].id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ec2-t2micro"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-8083-users"
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

resource "aws_autoscaling_group" "users" {
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1

  launch_template {
    id = aws_launch_template.users.id
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