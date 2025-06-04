variable "environment" {
  description = "Environments string"
  type        = string
}

variable "company" {
  type = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "Resource Group Name to organize env-based resources (optional, a new one would be created if not provided)"
  type        = string
}

variable "name" {
  description = "Key Vault name"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name)) && !contains(["windows", "microsoft", "azure"], lower(var.name))
    error_message = "Key Vault name is invalid or contains a reserved term like 'windows', 'microsoft', or 'azure'."
  }
}

variable "sku_name" {
  description = "SKU name"
  type        = string
}

variable "private_ip" {
  description = "Key Vault private IP"
  type        = string
}

variable "my_ip" {
  description = "My static IP"
  type        = string
}

variable "subnet_id" {
  description = "Key Vault subnet ID"
  type        = string
}

variable "keyvault_dns_zone_name" {
  type = string
}