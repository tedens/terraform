resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Fanout VPC"
    }
    enable_dns_hostnames = true
}

resource "aws_subnet" "public1" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)
    availability_zone = "us-east-1a"
    tags = {
        Name = "Public Subnet 1"
    }
}
resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)
    availability_zone = "us-east-1b"
    tags = {
        Name = "Public Subnet 2"
    }
}
resource "aws_subnet" "private1" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 2)
    availability_zone = "us-east-1c"
    tags = {
        Name = "Private Subnet 1"
    }
}
resource "aws_subnet" "private2" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 3)
    availability_zone = "us-east-1d"
    tags = {
        Name = "Private Subnet 2"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "Fanout IG"
    }
}


resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = {
        Name = "Public RT"
    }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }

  tags = {
    Name = "Private RT"
  }
}


# resource "aws_nat_gateway" "main" {
#     allocation_id = aws_eip.pub1.id
#     depends_on = [aws_eip.pub1]
#     subnet_id = aws_subnet.public1.id
#     tags = {
#         Name = "Public NatGateway 1"
#     }
# }

resource "aws_eip" "pub1" {
    vpc = true
}
resource "aws_eip" "pub2" {
    vpc = true
}

resource "aws_network_acl" "pub" {
    vpc_id = aws_vpc.main.id
    subnet_ids = [
        aws_subnet.public1.id,
        aws_subnet.public2.id
    ]
    ingress {
        protocol   = -1
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }
    egress {
        protocol   = -1
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }
    tags = {
        Name = "Public ACL"
    }
}
resource "aws_network_acl" "priv" {
    vpc_id = aws_vpc.main.id
    subnet_ids = [
        aws_subnet.private1.id,
        aws_subnet.private2.id
    ]
    ingress {
        protocol   = -1
        rule_no    = 100
        action     = "allow"
        cidr_block = aws_vpc.main.cidr_block
        from_port  = 0
        to_port    = 0
    }
    ingress {
        protocol   = "tcp"
        rule_no    = 110
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535
    }
    egress {
        protocol   = -1
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }
    tags = {
        Name = "Private ACL"
    }
}

resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.public1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
    subnet_id = aws_subnet.public2.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "c" {
    subnet_id = aws_subnet.private1.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "d" {
    subnet_id = aws_subnet.private2.id
    route_table_id = aws_route_table.private.id
}

resource "aws_main_route_table_association" "main" {
    vpc_id = aws_vpc.main.id
    route_table_id = aws_route_table.public.id

}
