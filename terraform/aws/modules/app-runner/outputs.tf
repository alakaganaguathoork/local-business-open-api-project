output "apprunner_service_url" {
  description = "URL of the App Runner service"
  value       = aws_apprunner_service.app.service_url
}