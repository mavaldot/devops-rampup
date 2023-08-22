resource "aws_security_group" "bastion_sg" {
  name = "bastion-sg"
  description = "Security group for the bastion ec2"
  vpc_id = var.my_vpc

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
    ami = "ami-09f67f6dc966a7829"
    instance_type = "t2.micro"
    subnet_id = var.public_subnet_1
    key_name = aws_key_pair.rsa_key.key_name
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]

    tags = {
        Name = "bastion"
        project = var.project
        responsible = var.responsible
    }

    volume_tags = {
        project = var.project
        responsible = var.responsible
    }
}