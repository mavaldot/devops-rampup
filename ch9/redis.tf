resource "aws_security_group_rule" "sg_redis_bastion_rule" {

    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = aws_security_group.ec2_sg["ec2-redis-sg"].id
    source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "sg_redis_vpc_rule" {

    type = "ingress"
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["10.1.0.0/16"]

    security_group_id = aws_security_group.ec2_sg["ec2-redis-sg"].id
}

resource "aws_instance" "redis" {
  ami           = "ami-09f67f6dc966a7829"
  instance_type = "t2.small"
  key_name      = aws_key_pair.rsa_key.key_name
  subnet_id = var.private_subnet_1

  user_data = base64encode( <<-EOF
    #!/bin/bash
    cd ~
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run -dp 6379:6379 redis:latest
    EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2_sg["ec2-redis-sg"].id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "redis"
    project = var.project
    responsible = var.responsible
  }

  volume_tags = {
    project = var.project
    responsible = var.responsible
  }
}