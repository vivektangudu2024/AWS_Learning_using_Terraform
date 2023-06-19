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

resource "aws_eks_cluster" "my_cluster" {

    name     = "my-eks-cluster"
    role_arn = aws_iam_role.IAM_Role.arn

    vpc_config {
        subnet_ids = [aws_subnet.my_subnet.id, aws_subnet.my_subnet_1.id]
    }

    depends_on = [
        aws_iam_role_policy_attachment.EKS_Cluster_Policy,
        aws_iam_role_policy_attachment.EKS_VPC_Resource_Controller,
    ]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "IAM_Role" {
  name               = "EKS"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "EKS_Cluster_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.IAM_Role.name
}

resource "aws_iam_role_policy_attachment" "EKS_VPC_Resource_Controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.IAM_Role.name
}

# output "kubeconfig" {
#   value = aws_eks_cluster.my_cluster.kubeconfig
# }

output "cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}

output "endpoint" {
  value = aws_eks_cluster.my_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.my_cluster.certificate_authority[0].data
}
