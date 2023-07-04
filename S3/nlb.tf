# Define variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "nlb_name" {
  description = "Name of the Network Load Balancer"
  type        = string
}

# Create Network Load Balancer
resource "aws_lb" "nlb" {
  name               = var.nlb_name
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnets # List of private subnets in your VPC
}

# Create Target Group
resource "aws_lb_target_group" "eks_target_group" {
  name     = "eks-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id # VPC ID of your VPC
}

# Create Listener
resource "aws_lb_listener" "eks_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.eks_target_group.arn
    type             = "forward"
  }
}

# Add Target Group to EKS Cluster
resource "kubernetes_service" "nlb_service" {
  metadata {
    name = "nlb-service"
    labels = {
      app = "my-app"
    }
  }

  spec {
    selector = {
      app = "my-app"
    }

    type = "LoadBalancer"

    ports {
      port        = 80
      target_port = 80
    }

    load_balancer_source_ranges = ["0.0.0.0/0"] # Adjust the allowed source IP ranges as per your requirements

    load_balancer {
      target_group_arn = aws_lb_target_group.eks_target_group.arn
      type             = "nlb"
    }
  }
}
