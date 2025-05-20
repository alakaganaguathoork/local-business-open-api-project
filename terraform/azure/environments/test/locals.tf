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
  subnet_north = "172.16.10.1/24"
}

locals {
  subnet_west = "172.16.20.1/24"
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
      os_type  = local.os_type_linux
      location = local.location_north
      sku_name = "B1"
      subnet   = local.subnet_north
    },
    "${local.app_name}-${local.location_west}" = {
      os_type  = local.os_type_linux
      location = local.location_west
      sku_name = "B1"
      subnet   = local.subnet_west
    }
  }
}