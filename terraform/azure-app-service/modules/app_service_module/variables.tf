variable "app_name" {
  description = "The lower-case name of this test app for resources"
  type = string
}

variable "apps" {
  description = "List of instances"
  type = map(object({
      name                = string,
      resource_group_name = string,
      location            = string,
      service_plan_name   = string
      allowed_ips         = list(string),
      environment         = string
  }))
}