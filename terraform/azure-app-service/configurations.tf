locals {
  app_name = "local-business"
}

locals {
  location = "northeurope"
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
      name                = "app-1",
      resource_group_name = "resource-group"
      location            = local.location
      service_plan_name   = "service-plan"
      allowed_ips         = local.allowed_ips
      environment         = "test"
      os_type             = "linux"
    },
    instance-2 = {
      name                = "app-2",
      resource_group_name = "resource-group"
      location            = local.location
      service_plan_name   = "service-plan"
      allowed_ips         = local.allowed_ips
      environment         = "dev"
      os_type             = "windows"
    },
    instance-3 = {
      name                = "app-3",
      resource_group_name = "resource-group"
      location            = local.location
      service_plan_name   = "service-plan"
      allowed_ips         = local.allowed_ips
      environment         = "stage"
      os_type             = "linux"
    },
  }
}

locals {
  instance = {
    instance-1 = {
      name                = "app-1",
      resource_group_name = "resource-group"
      location            = local.location
      service_plan_name   = "service-plan"
      allowed_ips         = local.allowed_ips
      environment         = "test"
      os_type            = "linux"
    }
  }
}
