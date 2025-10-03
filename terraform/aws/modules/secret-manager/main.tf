# module "rotation_lambda" {
#   source = "../lambda"
#   
#   function_name = ""
#   function_role = ""
# }

resource "random_id" "random" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "secret" {
  name                           = "${var.secret.name}-${random_id.random.hex}"
  description                    = var.secret.description
  force_overwrite_replica_secret = true


  tags = {
    Name = "${terraform.workspace}-${var.secret.name}"
  }
}

data "aws_secretsmanager_random_password" "new" {
  count = var.secret.generate ? 1 : 0

  password_length     = 20
  exclude_numbers     = false
  exclude_punctuation = true
  include_space       = false
}

resource "aws_secretsmanager_secret_version" "latest" {
  count         = (var.secret.secret_string != null || var.secret.generate) ? 1 : 0
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret.secret_string != null ? var.secret.secret_string : data.aws_secretsmanager_random_password.new[0].random_password
}

resource "aws_secretsmanager_secret_rotation" "days_30" {
  count = var.secret.rotate ? 1 : 0

  secret_id           = aws_secretsmanager_secret.secret.id
  rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:MyRotationFunction"
  # rotation_lambda_arn = module.rotation_lambda.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_iam_policy" "secret_policy" {
  name        = "${aws_secretsmanager_secret.secret.name}-get"
  description = "Allow read-only access to the secret ${aws_secretsmanager_secret.secret.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "${aws_secretsmanager_secret.secret.arn}"
      }
    ]
  })

  tags = {
    Name = "${aws_secretsmanager_secret.secret.name}-get"
  }
}
