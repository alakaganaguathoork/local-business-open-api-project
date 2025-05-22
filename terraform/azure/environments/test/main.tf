terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.24.0"
    }
    random = {
      source  = "hashicorp/random",
      version = "3.7.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {
}

module "env-infra" {
  source      = "../../modules/env-infra"
  environment = local.environment
  location    = local.location
  subnets     = local.subnets
  apps        = local.apps
  keyvault    = local.keyvault
}