resource "aws_ecr_repository" "app" {
  name         = var.app_name
  force_delete = true
}

resource "docker_image" "app_image" {
  name         = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
  build {
    context    = "${var.build_context}"
    # dockerfile = "${var.build_context}/Dockerfile"
    no_cache = true
    force_remove = true
  }
  
  keep_locally = false
  force_remove = true
}

resource "docker_registry_image" "media-handler" {
  name = docker_image.app_image.name
}