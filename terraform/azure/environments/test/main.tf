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


module "networking" {
  source      = "../../modules/networking"
  environment = local.environment
  instances   = local.instances
}

module "app_service" {
  source      = "../../modules/app-service"
  environment = local.environment
  instances   = local.instances
  subnets = module.networking.subnets

  depends_on = [ module.networking ]
}