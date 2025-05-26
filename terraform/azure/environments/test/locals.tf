locals {
  environment = "test"
}

locals {
  local_app_id = "local"
}

locals {
  random_app_id = "random"
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
  sku_name_for_app = "B1"
}

locals {
  sku_name_for_keyvault = "standard"
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
    "mysql" = {
      address_prefixes = ["10.0.100.0/24"]
      delegated        = false
      private_endpoint_policies_enabled     = true
      private_link_service_policies_enabled = true
    },
    "keyvault" = {
      address_prefixes = ["10.0.101.0/24"]
      delegated        = false
      private_endpoint_policies_enabled     = true
      private_link_service_policies_enabled = true
    },
  }
}

locals {
  apps = {
    (local.local_app_id) = {
      name = local.local_app_id
      os_type  = local.os_type.linux
      sku_name = local.sku_name_for_app
      address_prefixes = [ "10.0.0.0/24" ]
      delegated = true
      kv_ip = "10.0.101.10"
      private_endpoint_policies_enabled     = false
      private_link_service_policies_enabled = false
    },
    (local.random_app_id) = {
      name = local.random_app_id
      os_type  = local.os_type.linux
      sku_name = local.sku_name_for_app
      kv_ip = "10.0.101.20"
      address_prefixes = [ "10.0.1.0/24" ]
      delegated = true
      private_endpoint_policies_enabled     = false
      private_link_service_policies_enabled = false
    }
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