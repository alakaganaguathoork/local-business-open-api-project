variable "environment" {
  description = "Environment string"
  type = string
}

variable "instances" {
  description = ""
  type = map(object({
    location = string
    subnet = string 
  }))
}