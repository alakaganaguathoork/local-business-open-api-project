variable "secret" {
  type = object({
    name          = string
    description   = string
    secret_string = optional(string, null)
    rotate        = optional(bool, false)
    generate      = optional(bool, false)
  })
  description = "Secret object"
  sensitive   = true

  validation {
    condition     = (var.secret.secret_string != null || var.secret.secret_string != "") || var.secret.generate == true
    error_message = "`generate` should be true if no `secret_string` provided"
  }
}

variable "rotation_lambda_arn" {
  type        = string
  description = "ARN of lambda function which used for secrets rotation"
  default     = null

  validation {
    condition     = var.secret.rotate == false || (var.secret.rotate == true && var.rotation_lambda_arn != null && var.rotation_lambda_arn != "")
    error_message = "Rotation labda function ARN should be provided if `rotate` was set"
  }
}
