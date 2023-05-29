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
  region = "us-west-2"
  profile = "default"
}

//This gets the cannonical id of the user for permissions
data "aws_canonical_user_id" "current" {}


// Creating S3 bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "random1stbucket"  
}

// To enable versioning
resource "aws_s3_bucket_versioning" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

// To Upload File to S3 Bucket
resource "aws_s3_object" "test_object" {
  bucket = aws_s3_bucket_versioning.test_bucket.id  
  key    = "Test_File"  
  source = pathexpand("./test_file.txt")  
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
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-config" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.test_bucket]

  bucket = aws_s3_bucket.test_bucket.id

  rule {
    id = "config"

    filter {
      prefix = "config/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}
