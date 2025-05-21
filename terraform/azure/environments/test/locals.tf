locals {
  environment = "test"
}

locals {
  app_name = "local-business"
}

locals {
  location = "northeurope"
}

locals {
  os_type = {
    linux   = "Linux"
    windows = "Windows"
  }
}

locals {
  subnets = {
    subnet_10 = "172.16.10.0/24",
    subnet_20 = "172.16.20.0/24"
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
    "${local.app_name}-1" = {
      os_type  = local.os_type.linux
      location = local.location
      sku_name = "B1"
      subnet   = local.subnets.subnet_10
      delegated = true
    },
    "${local.app_name}-2" = {
      os_type  = local.os_type.linux
      location = local.location
      sku_name = "B1"
      subnet   = local.subnets.subnet_20
      delegated = true
    }
  }
}