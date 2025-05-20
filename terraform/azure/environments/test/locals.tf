locals {
  environment = "test"
}

locals {
  app_name = "local-business"
}

locals {
  os_type_linux = "Linux"
}

locals {
  os_type_windows = "Windows"
}
locals {
  location_north = "northeurope"
}

locals {
  location_west = "westeurope"
}

locals {
  resource_group = local.environment
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
    "${local.app_name}-${local.location_north}" = {
      environment = local.environment
      os_type     = local.os_type_linux
      location    = local.location_north
      sku_name    = "B1"
      subnet      = ""
    },
    "${local.app_name}-${local.location_west}" = {
      environment = local.environment
      os_type     = local.os_type_linux
      location    = local.location_west
      sku_name    = "B1"
      subnet      = ""
    }
  }
}