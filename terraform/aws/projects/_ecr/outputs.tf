output "repository_url" {
  value = {
    for key, value in module.ecr :
    key => value.repository_url
  }
}