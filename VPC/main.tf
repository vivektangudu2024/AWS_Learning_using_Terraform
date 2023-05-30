terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

# Create VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ExampleVPC"
  }
}

# Create subnets
resource "aws_subnet" "example_subnet1" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ExampleSubnet1"
  }
}

resource "aws_subnet" "example_subnet2" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "ExampleSubnet2"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "ExampleInternetGateway"
  }
}


/*
# Attach internet gateway to VPC
resource "aws_internet_gateway_attachment" "example_igw_attachment" {
  vpc_id             = aws_vpc.example_vpc.id
  internet_gateway_id = aws_internet_gateway.example_igw.id
}
*/

# Create route table
resource "aws_route_table" "example_rt" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "ExampleRouteTable"
  }
}

# Create route to the internet gateway
resource "aws_route" "example_rt_route" {
  route_table_id         = aws_route_table.example_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example_igw.id
}

# Associate subnets with the route table
resource "aws_route_table_association" "example_subnet1_association" {
  subnet_id      = aws_subnet.example_subnet1.id
  route_table_id = aws_route_table.example_rt.id
}

resource "aws_route_table_association" "example_subnet2_association" {
  subnet_id      = aws_subnet.example_subnet2.id
  route_table_id = aws_route_table.example_rt.id
}

# Create network ACL
resource "aws_network_acl" "example_nacl" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "ExampleNetworkACL"
  }
}

# Create network ACL rules
resource "aws_network_acl_rule" "example_nacl_inbound_rule" {
  network_acl_id = aws_network_acl.example_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "example_nacl_outbound_rule" {
  network_acl_id = aws_network_acl.example_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Create security group
resource "aws_security_group" "example_sg" {
  vpc_id      = aws_vpc.example_vpc.id
  name        = "ExampleSecurityGroup"
  description = "Example security group for fine-grained network access control"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ExampleSecurityGroup"
  }
}

