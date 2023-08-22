resource "aws_security_group_rule" "sg_zipkin_bastion_rule" {

    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-zipkin-sg"].id
    source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "sg_zipkin_alb_rule" {

    type = "ingress"
    from_port = 9411
    to_port = 9411
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-zipkin-sg"].id
    source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_launch_template" "zipkin" {
  name = "zipkin"
  image_id           = "ami-09f67f6dc966a7829"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.rsa_key.key_name

  user_data = base64encode( <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --rm -dp 9411:9411 openzipkin/zipkin
    EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2_sg["ec2-zipkin-sg"].id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ec2-t2micro"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-9411-zipkin"
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

resource "aws_autoscaling_group" "zipkin" {
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1

  launch_template {
    id = aws_launch_template.zipkin.id
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