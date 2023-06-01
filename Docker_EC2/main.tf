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
    region = "us-east-1"
}

//Variables
variable "path_to_private_key" {
  type = string
}

variable "path_to_local_image_file" {
  type = string
}

//Creating EC2 Instance
resource "aws_instance" "myInstance" {
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_private_key.key_name

//Connecting to instance using SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.path_to_private_key)  # Replace with the path to your private key
    host        = self.public_ip
  }

//Commands to run in SSH terminal
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
    ]
  }

//Commands to run outside SSH terminal
  provisioner "local-exec" {
    command = "scp -i ${var.path_to_private_key} ${var.path_to_local_image_file} ubuntu@${self.public_ip}:~/image.tar"
  }

//Commands to run in SSH terminal
  provisioner "remote-exec" {
    inline = [
      "sudo docker load -i ~/image.tar",
      "sudo docker run -d -p 80:80 hello-world-app:latest"
    ]
  }


//Security Groups
  vpc_security_group_ids = [aws_security_group.mySG.id]

//Tags
  tags = {
    Name = "My Instance"
  }
}

//Creating an AWS key pair
resource "aws_key_pair" "my_private_key" {
  key_name   = "my_private_key" 
  public_key = file("/home/shantanu/.ssh/my_private_key.pub")
}

//Creating Security Groupt
resource "aws_security_group" "mySG" {
  name        = "mySecurityGroup"

//Inbound
//Port 80 for http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

// Port 22 for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

//Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}






