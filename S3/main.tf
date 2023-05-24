//Declaring Reuired Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}

//Configuring a Provider
provider "aws" {
  region = "us-east-1"
  shared_credentials_files = [pathexpand("~/.aws/credentials")]
  profile = "default"
}

//Creating a variable with canonical id in it
variable "canonical_id" {
  type = string
  description = "User Canonical ID"
}

// Creating S# bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "random1stbucket"
}

// To Upload File to S3 Bucket
resource "aws_s3_object" "test_object" {
  bucket = aws_s3_bucket.test_bucket.id  
  key    = "Test_File"  
  source = pathexpand("~/Videos/S3_Terraform/test_file.txt")  
}

//Creating Ownership controls
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.test_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

//Creating Access Control List of Bucket
resource "aws_s3_bucket_acl" "test_bucket_acl" {
  bucket = aws_s3_bucket.test_bucket.id  # Reference the bucket resource
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
  access_control_policy {
    grant {
      grantee {
        id   = var.canonical_id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = var.canonical_id
    }
  }
}