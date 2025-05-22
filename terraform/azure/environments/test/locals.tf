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
    linux   = "linux"
    windows = "windows"
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
  subnets = {
    "app" = {
      address_prefixes = ["10.0.1.0/24"]
      delegated        = true
      private_endpoint = false
    },
    "mysql" = {
      address_prefixes = ["10.0.2.0/24"]
      delegated        = false
      private_endpoint = true
    },
    "keyvault" = {
      address_prefixes = ["10.0.3.0/24"]
      delegated        = false
      private_endpoint = true
    },
  }
}

locals {
  apps = {
    # "${local.app_name}-1" = {
    # os_type  = local.os_type.linux
    # sku_name = "B1"
    # },
    # "${local.app_name}-2" = {
    # os_type  = local.os_type.linux
    # sku_name = "B1"
    # }
  }
}

locals {
  keyvault = {
  sku_name   = "standard"
  access_policies = {
    object = {
      key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
    },
    principal = {
      key_permissions = ["Get", "WrapKey", "UnwrapKey"]
    }}
  }
}