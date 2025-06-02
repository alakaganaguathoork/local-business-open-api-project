variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name to organize env-based resources (optional, a new one would be created if not provided)"
  type        = string
}

variable "name" {
  description = "App Name string"
  type        = string
}

variable "os_type" {
  description = "OS type. Possible values: `Linux` / `linux`, `Windows` / `windows`"
  type        = string

  validation {
    condition = contains(["linux", "windows"], lower(var.os_type))
    # condition     = lower(var.os_type) == lower("linux") || lower(var.os_type) == "windows"
    error_message = "The `os_type` value is invalid. Possible values: `Linux` / `linux`, `Windows` / `windows`"
  }
}

variable "sku_name" {
  description = "Stock Keeping Unit type. A default 'B1' is used"
  type        = string
  default     = "B1"

  validation {
    condition     = var.sku_name == "B1"
    error_message = "The `sku_name` is invalid. Should be 'B1' for this test infra"
  }
}

variable "docker_image" {
  description = "App docker image reference"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for an app to be assigned"
  type        = string
}

# variable "storage_account" {
# description = "BYOS storage mount configuration"
# type = object({
# primary_access_key   = string
# account_name = string
# name         = string
# share_name   = string
# type         = string
# mount_path   = string
# })
# default = null
# }

variable "keyvault_id" {
  type = string
}

variable "storage_account" {
  type = any
}