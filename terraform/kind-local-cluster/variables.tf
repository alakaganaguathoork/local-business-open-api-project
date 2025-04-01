variable "namespace" {
  description = "Kubernetes' namespace name"
  type        = string
  default     = "local"
}

variable "docker_image_name" {
  description = "App's docker image name"
  type        = string
  default     = "local-business-open-api"
}