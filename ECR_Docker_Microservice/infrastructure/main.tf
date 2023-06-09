#create an ecr
resource "aws_ecr_repository" "microservice" {
  name = "microservice"
}
#build docker image and push to ecr
resource "docker_image" "image" {
  name = "${aws_ecr_repository.microservice.repository_url}:latest"
  build {
    path = "../application"
    dockerfile = "Dockerfile"
  }
}
resource "docker_registry_image" "micro" {
  name = docker_image.image.name

  
}

resource "aws_ecr_lifecycle_policy" "my_lifecycle_policy" {
  repository = aws_ecr_repository.microservice.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 30 days",
      "selection": {
        "tagStatus": "any",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}


resource "aws_instance" "ec2" {
  depends_on = [ docker_registry_image.micro ]
  ami                    = "ami-0dc2d3e4c0f9ebd18"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  key_name               = aws_key_pair.default.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data_base64       = filebase64("${path.module}/user_data.sh")
}

/*
# SSL Certificate
resource "aws_acm_certificate" "ssl_certificate" {
  #provider                  = aws.acm_provider
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "EMAIL"
  #validation_method         = "DNS"

  #tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Uncomment the validation_record_fqdns line if you do DNS validation instead of Email.
resource "aws_acm_certificate_validation" "cert_validation" {
  #provider        = aws.acm_provider
  certificate_arn = aws_acm_certificate.ssl_certificate.arn
  #validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_elb" "main" {
  name               = "foobar-terraform-elb"
  availability_zones = ["us-east-1c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
   #ssl_certificate_id  = aws_acm_certificate.ssl_certificate.id
  }
}*/
