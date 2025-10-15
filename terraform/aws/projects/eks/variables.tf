variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "sg_allowed_ips_list" {
  type = list(string)
  description = "List of IPs to access the application." 
}

variable "my_public_ssh_key" {
  type = string
}

# access.tf
variable "access_users" {
  type = list(string)
  description = "A list of IAM user ARNs for users who need access to the EKS cluster."
}

# main.tf
variable "cluster" {
  type = object({
    name = string
    k8s_version = string
  })
}

variable "cluster_addons" {
  type = map(object({
    addon_name    = string
    addon_version = string
  }))
}

variable "node_groups" {
  type = map(object({
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    instance_types = list(string)
  }))
  description = "A map of node group configurations." 
}
