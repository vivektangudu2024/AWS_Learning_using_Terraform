resource "aws_subnet" "sub_1_private" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/19"
    availability_zone = "us-east-1a"

    tags = {
      name = "Private Subnet 1"
    }
}

resource "aws_subnet" "sub_2_private" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.32.0/19"
    availability_zone = "us-east-1b"

    tags = {
      name = "Private Subnet 2"
    }
}

resource "aws_subnet" "sub_1_public" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.64.0/19"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
      name = "Public Subnet 1"
    }
}

resource "aws_subnet" "sub_2_public" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.96.0/19"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
      name = "Public Subnet 2"
    }
}

