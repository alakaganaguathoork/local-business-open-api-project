locals {
  app_name = "local-business"
}

locals {
  location = "northeurope"
}

locals {
  subnets = {
    integration_subnet = {
      name             = "integration",
      address_prefixes = ["10.0.1.0/24"],
      delegated        = true,
      private_endpoint = false
    },
    endpoint_subnet = {
      name             = "endpoint",
      address_prefixes = ["10.0.2.0/24"],
      delegated        = false,
      private_endpoint = true
    }
  }
}

locals {
  allowed_ips = [
    "194.62.136.215/32",
    "194.62.136.216/32",
    "10.10.1.0/16"
  ]
}

locals {
  instances = {
    instance-1 = {
      name                = "${local.app_name}-app-1",
      resource_group_name = "${local.app_name}-rg-1",
      location            = local.location,
      service_plan_name   = "${local.app_name}-sp-1",
      allowed_ips         = local.allowed_ips,
      environment         = "test",
      os_type             = "linux",
      subnet_id           = module.vnet.integration_subnet_id
    },
    instance-2 = {
      name                = "${local.app_name}-app-2",
      resource_group_name = "${local.app_name}-rg-2"
      location            = local.location,
      service_plan_name   = "${local.app_name}-sp-2",
      allowed_ips         = local.allowed_ips,
      environment         = "dev",
      os_type             = "windows",
      subnet_id           = module.vnet.integration_subnet_id

    },
    instance-3 = {
      name                = "${local.app_name}-app-3",
      resource_group_name = "${local.app_name}-rg-3",
      location            = local.location,
      service_plan_name   = "${local.app_name}-sp-3",
      allowed_ips         = local.allowed_ips,
      environment         = "stage",
      os_type             = "linux",
      subnet_id           = module.vnet.integration_subnet_id

    }
  }
}

locals {
  instance = {
    instance-1 = {
      name                = "${local.app_name}-app-1",
      resource_group_name = "${local.app_name}-rg-1"
      location            = local.location,
      service_plan_name   = "${local.app_name}-sp-1",
      allowed_ips         = local.allowed_ips,
      environment         = "test",
      os_type             = "linux",
      subnet_id           = module.vnet.integration_subnet_id
    }
  }
}
