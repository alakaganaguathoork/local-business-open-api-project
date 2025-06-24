data "aws_caller_identity" "current" {}

locals {
  ecr_registry_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}

resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "${var.app_name}-connector"
  subnets            = [var.subnet_id]
  security_groups    = var.security_group_id
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
        port = "5400"
      }
    }

    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }
  
  network_configuration {
    egress_configuration {
      egress_type = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
  }

  health_check_configuration {
    path                = "/test" # no needed for "TCP" protocol
    interval            = 10    # seconds between checks
    timeout             = 2     # seconds to wait for response
    healthy_threshold   = 1     # consecutive successes for healthy
    unhealthy_threshold = 4     # consecutive failures for unhealthy
    protocol = "HTTP"
  }

    depends_on = [ aws_apprunner_vpc_connector.connector ]
}

