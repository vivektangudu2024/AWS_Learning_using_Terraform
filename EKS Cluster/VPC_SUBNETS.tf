resource "aws_vpc" "my_vpc" {
  cidr_block = "172.31.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "172.31.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "My Subnet"
  }
}

resource "aws_subnet" "my_subnet_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "172.31.32.0/20"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"

  tags = {
    Name = "My Subnet 1"
  }
}