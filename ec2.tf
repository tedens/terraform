data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
    owners = ["099720109477"]
}

resource "aws_security_group" "main" {
    name = "terra-sg"
    description = "Basic 80 and 22 open"
    vpc_id = aws_vpc.main.id
    ingress {
        description = "HTTP from VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH Port (home)"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["208.59.188.72/32", "10.0.0.0/16"]
    }
    ingress {
        description = "Ping Port"
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "allow_http_ssh"
    }
}

resource "aws_instance" "pub" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public1.id
    key_name = "terra"
    associate_public_ip_address = true
    security_groups = [aws_security_group.main.id]
    tags = {
        Name = "Public EC2 1"
    }
}

resource "aws_instance" "priv" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    tags = {
        Name = "Private EC2 1"
    }
    subnet_id = aws_subnet.private1.id
    key_name = "terra"
    security_groups = [aws_security_group.main.id]
}