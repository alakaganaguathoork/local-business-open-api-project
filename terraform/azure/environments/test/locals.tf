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

# locals {
# subnets = {
# subnet_10 = "172.16.10.0/24",
# subnet_20 = "172.16.20.0/24"
# }
# }

locals {
  allowed_ips = [
    "194.62.136.215/32",
    "194.62.136.216/32",
    "10.10.1.0/16"
  ]
}

locals {
  subnets = {
    "app" = {
      address_prefixes   = [ "10.0.1.0/24" ]
      delegated        = true
      private_endpoint = false
    },
    "mysql" = {
      address_prefixes   = [ "10.0.2.0/24" ]
      delegated        = false
      private_endpoint = true
    },
    "keyvault" = {
      address_prefixes   = [ "10.0.3.0/24" ]
      delegated        = false
      private_endpoint = true
    },
  }
}

locals {
  instances = {
    "${local.app_name}-1" = {
      type       = "app"
      os_type    = local.os_type.linux
      location   = local.location
      sku_name   = "B1"
      networking = local.subnets.app
    },
    # "${local.app_name}-2" = {
    # type = "app"
    # os_type  = local.os_type.linux
    # location = local.location
    # sku_name = "B1"
    # networking = {
    # subnet = local.subnets.subnet_20
    # delegated = false,
    # public_ip        = true,
    # private_endpoint = true
    # 
    # }
    # }
  }
}

locals {
  keyvault = {
    type       = "keyvault"
    location   = local.location
    sku_name   = "Standard"
    networking = local.subnets.keyvault
    access_policies = {
      object = {
        key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
      },
      principal = {
        key_permissions = ["Get", "WrapKey", "UnwrapKey"]
      }
    }
  }
}