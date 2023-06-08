terraform {
    required_providers {
        mongodbatlas = {
            source  = "mongodb/mongodbatlas"
            version = "1.9.0"
        }
    }
}

variable "privateKey" {
  type  = string
}
variable "publicKey" {
  type  = string
}
variable "orgID" {
  type  = string
}
variable "apiKey" {
  type  = string
}

provider "mongodbatlas" {
    region = "us-east-1"
    private_key = var.privateKey
    public_key = var.publicKey
}

resource "mongodbatlas_project" "Test" {
  name   = "Test Project"
  org_id = var.orgID
}

resource "mongodbatlas_cluster" "MyCluster" {
  project_id = mongodbatlas_project.Test.id
  name = "MyCluster"
  cloud_backup = false
  provider_name = "TENANT"
  backing_provider_name = "AWS"
  provider_instance_size_name = "M0"
  provider_region_name = "US_EAST_1"

}

resource "mongodbatlas_project_ip_access_list" "test" {
  project_id = mongodbatlas_project.Test.id
  cidr_block = "0.0.0.0/0"
  comment    = "cidr block for tf acc testing"
}