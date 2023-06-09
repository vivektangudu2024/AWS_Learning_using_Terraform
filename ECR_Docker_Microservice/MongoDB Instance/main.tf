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


//Creating EC2 Instance
resource "aws_instance" "mongoDB_instance" {
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_private_key.key_name

  //Connecting to instance using SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("my_private_key")  # Replace with the path to your private key
    host        = self.public_ip
  }

  //Commands to run in SSH terminal
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install gnupg",
      "curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor",
      "echo \"deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse\" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list",
      "sudo apt-get update",
      "sudo apt-get install -y mongodb-org",
      "sudo systemctl enable mongod",
      "sudo systemctl start mongod",
      "sudo sed -i 's/bindIp: .*/bindIp: 0.0.0.0/' /etc/mongod.conf",
      "sudo systemctl restart mongod"
    ]
  }
  //Security Groups for the EC2 Instance
  vpc_security_group_ids = [aws_security_group.sg_db.id]

  //Tags
  tags = {
    Name = "MongoDB Instance"
  }
}

//Creating an AWS key pair
resource "aws_key_pair" "my_private_key" {
  key_name   = "my_private_key" 
  public_key = file("my_private_key.pub")
}


//Creating Security Groups
resource "aws_security_group" "sg_db" {
  name        = "mySecurityGroup"

  //Inbound Rules
  //Port 80 for http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //Port 27017 for MongoDB
  ingress {
    from_port   = 27017
    to_port     = 27017
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

  //Outbound Rules
  //All Ports and all Protocols
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "pulic_ip_mongoDB" {
  value = aws_instance.mongoDB_instance.public_ip
}
