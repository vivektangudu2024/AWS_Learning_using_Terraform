terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    docker = {
        source  = "kreuzwerker/docker"
        version = "2.15.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}

provider "docker" {
  
  host    = "npipe:////.//pipe//docker_engine"
  registry_auth {
    address  = local.aws_ecr_url
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}