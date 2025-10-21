variable "environment" {
  description = "The deployment environment (e.g., test, dev)."
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}