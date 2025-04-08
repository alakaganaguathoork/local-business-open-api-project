terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.24.0"
    }
  }
}
provider "azurerm" {
  features {}

  subscription_id = var.az_subscription_id
  client_id       = var.az_client_id
  client_secret   = var.az_client_secret
  tenant_id       = var.az_tenant_id
}

#resource group
# resource "azurerm_resource_group" "devops-demo" {
#   name     = "devops-demo"
#   location = "West Europe"
# }

#