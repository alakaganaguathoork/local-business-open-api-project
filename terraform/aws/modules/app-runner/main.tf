data "aws_caller_identity" "current" {}

locals {
  ecr_registry_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}

data "aws_iam_policy_document" "apprunner_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com", "apprunner.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "app_runner_role" {
  name               = "${var.app_name}-apprunner-role"
  assume_role_policy = data.aws_iam_policy_document.apprunner_assume.json
}

resource "aws_iam_role_policy_attachment" "apprunner_policy" {
  role       = aws_iam_role.app_runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_apprunner_service" "app" {
  service_name = var.app_name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_role.arn
    }

    image_repository {
      image_identifier      = var.image_identifier
      image_repository_type = "ECR"

      image_configuration {
        port = "8080"
      }
    }

    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }

    health_check_configuration {
    path                = "/test"
    interval            = 10    # seconds between checks
    timeout             = 5     # seconds to wait for response
    healthy_threshold   = 2     # consecutive successes for healthy
    unhealthy_threshold = 4     # consecutive failures for unhealthy
    protocol = "HTTP"
  }
}

