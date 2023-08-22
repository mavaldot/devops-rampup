resource "aws_security_group_rule" "sg_todos_bastion_rule" {

    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-todos-sg"].id
    source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "sg_todos_alb_rule" {

    type = "ingress"
    from_port = 8082
    to_port = 8082
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-todos-sg"].id
    source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_launch_template" "todos" {
  name = "todos"
  image_id           = "ami-0f8e81a3da6e2510a"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.rsa_key.key_name

  user_data = base64encode( <<-EOF
    #!/bin/bash
    cd /home/ubuntu
    sudo apt update -y
    sudo apt install git -y
    sudo apt install -y npm nodejs
    git clone https://github.com/bortizf/microservice-app-example.git
    cd microservice-app-example/todos-api
    rm package-lock.json
    npm cache clean --force
    npm install >/home/ubuntu/build.log 2>&1
    sleep 60
    TODO_API_PORT=8082 JWT_SECRET=PRFT ZIPKIN_URL=http://${aws_lb.alb.dns_name}/api/v2/spans \
    REDIS_HOST=${aws_instance.redis.private_ip} REDIS_PORT=6379 REDIS_CHANNEL=log_channel npm start & >/home/ubuntu/log 2>/home/ubuntu/error.log
    EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2_sg["ec2-todos-sg"].id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ec2-t2micro"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-8082-todos"
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

resource "aws_autoscaling_group" "todos" {
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1

  launch_template {
    id = aws_launch_template.todos.id
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