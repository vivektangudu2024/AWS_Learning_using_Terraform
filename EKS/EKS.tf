resource "aws_iam_role" "Cluster_IAM_Role" {
    name = "EKSCluster"

    assume_role_policy = <<POLICY
    {
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.Cluster_IAM_Role.name
}

resource "aws_eks_cluster" "my_cluster" {
    name     = "myCluster"
    role_arn = aws_iam_role.Cluster_IAM_Role.arn

    vpc_config {
        subnet_ids = [
            aws_subnet.sub_1_private.id,
            aws_subnet.sub_2_private.id,
            aws_subnet.sub_1_public.id,
            aws_subnet.sub_2_public.id
        ]
    }

    depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]
}