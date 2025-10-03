output "secret_arn" {
  value = aws_secretsmanager_secret.secret.arn
}

output "secret_policy_arn" {
  value = aws_iam_policy.secret_policy.arn
}