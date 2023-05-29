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
  region  = "us-east-1"
}

locals {
  username       = var.username
  password       = var.password
  
}

resource "aws_db_instance" "example_rds" {
  identifier            = "example-db"
  engine                = "mysql"
  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  username              = local.username
  password              = local.password
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  skip_final_snapshot = true
  backup_retention_period = 7
  
  backup_window           = "03:00-04:00"
  multi_az = false
  tags = {
    Name = "Example RDS Instance"
  }
}

resource "aws_db_instance" "example_replica" {
  count                = 1
  engine               = aws_db_instance.example_rds.engine
  instance_class       = aws_db_instance.example_rds.instance_class
  identifier           = "${aws_db_instance.example_rds.identifier}-replica${count.index + 1}"
  skip_final_snapshot  = true
  // Enable read replicas for high availability
  replicate_source_db = aws_db_instance.example_rds.identifier

  

  tags = {
    Name = "Example RDS Replica ${count.index + 1}"
  }
}


resource "aws_security_group" "example_sg" {
  name        = "ExampleSecurityGroup"
  description = "Example security group for RDS"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

