terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.67.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.21.1"
        }
    }
    required_version = ">= 1.2.0"
}

provider "aws" {
    region = "us-east-1"
}

