terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.12.0"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
        Environment = var.env,
        Region = var.region
    }
  }
}

provider "docker" {
}

variable "env" {
  type = string
  # default = "test"
}

variable "region" {
  type = string
}

variable "availability_zone" {
  type = string
}
 
variable "vpc_cidr" {
  type = string
}

data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  region = data.aws_region.current.region
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "allow_tls" {
  name = "allow_tls"
  description =  "Allow TLS inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.main.id
}  

resource "aws_security_group_rule" "allow_ingress_tls" {
  security_group_id = aws_security_group.allow_tls.id
  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_blocks = [ aws_vpc.main.cidr_block ]
  # ipv6_cidr_blocks = [ aws_vpc.main.ipv6_cidr_block ]
}

resource "aws_security_group_rule" "allow_ingress_5400" {
  security_group_id = aws_security_group.allow_tls.id
  type = "ingress"
  protocol = "tcp"
  from_port = 5400
  to_port = 5400
  cidr_blocks = [ aws_vpc.main.cidr_block ]
  # ipv6_cidr_blocks = [ aws_vpc.main.ipv6_cidr_block ]
}

resource "aws_security_group_rule" "allow_egress_all_traffic" {
  security_group_id = aws_security_group.allow_tls.id
  type = "egress"
  protocol = "-1"
  from_port = 0
  to_port = 65535
  source_security_group_id = aws_security_group.allow_tls.id
}


resource "aws_ecr_repository" "main" {
  name = "main"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  tags = {
    Project = "Local App"
  }
}

resource "aws_ecr_lifecycle_policy" "image_expiration_policy" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
        {
            rulePriority = 1
            description = "Expire images older than 1 day"
            selection = {
                tagStatus = "untagged"
                countType = "sinceImagePushed"
                countUnit = "days"
                countNamber = 1
            }
            action = {
                type = "expire"
            }
        }
    ]
  })
}

resource "aws_ecr_repository_policy" "access_policy" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:user/alakaganaguathoork" 
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

resource "docker_image" "main" {
    name = "${aws_ecr_repository.main.repository_url}:latest"
    build {
        context = "/home/mishap/VSCodeProjects/local-business-open-api-project/"
    }
}

data "aws_ecr_authorization_token" "token" {}
data "aws_caller_identity" "current" {}

resource "docker_registry_image" "main" {
  name = docker_image.main.name

  depends_on = [ aws_ecr_repository.main ]

  auth_config {
    address = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.main.id
}

resource "aws_apprunner_connection" "github" {
  connection_name = "github"
  provider_type = "GITHUB"
}

resource "aws_apprunner_vpc_connector" "main" {
  vpc_connector_name = "main"
  subnets = [ aws_subnet.public.id ]
  security_groups = [ aws_security_group.allow_tls.id ]
}

resource "aws_apprunner_service" "main" {
  service_name = "local"

  source_configuration {
    image_repository {
      image_configuration {
        port = "5400"
      }
      image_identifier      = "public.ecr.aws/aws-containers/${aws_ecr_repository.main.repository_url}:latest"
      image_repository_type = "ECR_PUBLIC"
    }
    auto_deployments_enabled = false
  }

  tags = {
    Name = "Local"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "app_url" {
  value = aws_apprunner_service.main.service_url
}