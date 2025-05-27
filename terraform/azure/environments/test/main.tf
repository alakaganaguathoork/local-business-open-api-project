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

module "app-kv" {
  source      = "../../modules/app-kv"
  environment = local.environment
  location    = local.location
  vpc_cidr    = local.vpc_cidr
  env_data    = local.main
}