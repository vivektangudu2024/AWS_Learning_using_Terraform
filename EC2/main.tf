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
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}



resource "aws_security_group" "example_sg" {
  name        = "ExampleSecurityGroup"
  description = "Example security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}
/*
resource "aws_key_pair" "example_key_pair" {
  key_name   = "ExampleKeyPair"
  public_key = "ssh-rsa MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnFKAxSxm7GfkesxUB0icSYbmIRzI2fiNM3KBv8dkJ3IP+rLSOwB/ZwXorMqJNA/4Z5NUsxr1meW1nj4zNf/l6pUrM8Ceb7ltREAWyHqVkOp4Tv6OIcgdaaWORqz2ia6ihdC2+tSXylIcL3T/GRzgaR+ljguoplgmrkWCrVT+e6LGyiZZWPYBJcEfhDkIT619raZ8TuoVaTUxbsk/D9W2sM+5RyXWX6VugHPJ0eEHVScM2HmzeUyqvlxE/NqUm2H4xLkGWqfL3wt4ObGuBEt537eyyKKg7jgMxVYaMvA+FOrU8YePzRrmMzORJZJZxZWEpz/KrAdX+GphZHDiL3FsahJci0guquCcp6irf+sx1v/lUttk55r7GjyGyad4V3HhMbKikd/CPuLLYWVLD12mGIbSAlOB6/io7bbI45iPXmhg41STY5+9dAM58gD96oHz3uUdWapRZYeH4tngv4Dx9knWnUbcuiy8Y9kceWEdVO+bMKqhPaglyAdVvolL3U7a4/wWCxCy4dQNF5Rh5W/YbzcHxXmg5KpTtw4TNBHw46PG00bWmvVcjnV3lj/t/9tSPKQyg+q4qwI+Vont004lLTYCMiB8pX2Fmq6FV4k3rOdGwsCR+ppI+mIzUq2b5NnECc1Dd1UyO1/vu14LVi9NiEuneNUO5Ncyh9dv4hOrmdcCAwEAAQ=="
}
*/

resource "aws_autoscaling_group" "example_asg" {
  name                      = "ExampleAutoScalingGroup"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
 
  launch_configuration      = aws_launch_configuration.example_lc.name
  availability_zones = ["us-west-2a"]
  
}

resource "aws_launch_configuration" "example_lc" {
  name          = "ExampleLaunchConfiguration"
  image_id      = "ami-08d70e59c07c61a3a"  
  instance_type = "t2.micro"  
  
  
}

resource "aws_elb" "example_elb" {
  name               = "ExampleLoadBalancer"
  security_groups    = [aws_security_group.example_sg.id]
  availability_zones = ["us-west-2a", "us-west-2b"]  # Replace with desired availability zones

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  
}


