data "aws_ami" "bastion" {
    most_recent = true

    filter {
        name   = "name"
        values = ["*BastionServer*"]
    }

    owners = ["self"]
}



data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}

resource "aws_security_group" "bastion" {
    name = "Bastion SG"
    description = "Open 22 for bastion server"
    vpc_id = aws_vpc.main.id
    ingress {
        description = "TJs home"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["208.59.188.72/32"]
    }
    egress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.main.cidr_block]
    }
}

resource "aws_security_group" "db" {
    name = "Database SG"
    description = "Open 3306 for web server server"
    vpc_id = aws_vpc.main.id
    ingress {
        description = "DB port for VPC"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.web-server.id]
    }
    ingress {
        description = "SSH from VPC"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "web-server" {
    name = "WebServer SG"
    description = "Basic 80,433 and 22 open"
    vpc_id = aws_vpc.main.id
    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Bastion SG"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion.id]
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

resource "aws_instance" "wp" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public1.id
    key_name = "internal"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.web-server.id]
    iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
    tags = {
        Name = "Fanout WP"
    }
}

resource "aws_instance" "db" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    tags = {
        Name = "Fanout DB"
    }
    subnet_id = aws_subnet.private1.id
    key_name = "internal"
    vpc_security_group_ids = [aws_security_group.db.id]
    iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"

}

resource "aws_instance" "bastion" {
    ami = data.aws_ami.bastion.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public2.id
    key_name = "desktop"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.bastion.id]
    iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
    tags = {
        Name = "Fanout Bastion"
    }
}