variable "az_subscription_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "az_client_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "az_client_secret" {
  description = "Azure Tenant ID"
  type        = string
}


variable "az_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "az_storage_resource_group_name" {
  description = "Azure Resource Group name"
  type = string
  default = "tfstate"
}