data "aws_eks_cluster_auth" "my_cluster" {
  name = "myCluster"
}

# Create the Kubernetes provider to connect to the EKS cluster
provider "kubernetes" {
    host                   = aws_eks_cluster.my_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.my_cluster.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.my_cluster.token
}