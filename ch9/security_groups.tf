variable  "security_group_list" {
    type = list(string)
    default = ["ec2-frontend-sg", "ec2-auth-sg", "ec2-lmp-sg", "ec2-todos-sg", "ec2-users-sg", "ec2-redis-sg", "ec2-zipkin-sg"]
}

resource "aws_security_group" "ec2_sg" {
    for_each = toset(var.security_group_list)

    name = each.key

    vpc_id = var.my_vpc

    tags = {
        name = "SG ${each.key}"
        responsible = var.responsible
        project = var.project
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

    egress {
        from_port = 8083
        to_port = 8083
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 6379
        to_port = 6379
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/16"]
    }

}