# main.tf
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

resource "aws_instance" "web" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  //count         = 2

  # Add other configuration settings (e.g., VPC, subnet, security group)

  # Provision Docker container on EC2 instances
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo docker build  -f docker.dockerfile -t hello-world-microservice .
    sudo docker run -d -p 3000:3000 hello-world-microservice
EOF

}

resource "aws_elb" "lb" {
  name               = "my-load-balancer"
  security_groups    = [aws_security_group.lb.id]
  availability_zones = ["us-west-2a", "us-west-2b"]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    target              = "HTTP:3000/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  instances = aws_instance.web.*.id
}

resource "aws_security_group" "lb" {
  name        = "lb-security-group"
  description = "Security group for load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  min_size             = 2
  max_size             = 4
  health_check_type    = "ELB"
  health_check_grace_period = 300
  availability_zones = ["us-west-2a", "us-west-2b"]
  launch_configuration = aws_launch_configuration.lc.name

  tag {
    key                 = "Name"
    value               = "my-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "lc" {
  name                 = "my-lc"
  image_id             = "ami-08d70e59c07c61a3a"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.lb.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo docker build  -f docker.dockerfile -t hello-world-microservice .
    sudo docker run -d -p 3000:3000 hello-world-microservice
EOF

}

output "load_balancer_dns" {
  value = aws_elb.lb.dns_name
}
