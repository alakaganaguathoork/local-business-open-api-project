variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "access_users" {
  type = list(string)
  description = "A list of IAM user ARNs for users who need access to the EKS cluster."
}

variable "cluster" {
  type = object({
    name = string
    k8s_version = string
  })
}

variable "sg_allowed_ips_list" {
  type = list(string)
  description = "List of IPs to access the application." 
}

variable "security_groups" {
  type    = any
  default = {}
}
