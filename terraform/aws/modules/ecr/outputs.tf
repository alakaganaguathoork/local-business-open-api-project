output "repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "image_identifier" {
  value = docker_image.app_image.name
}