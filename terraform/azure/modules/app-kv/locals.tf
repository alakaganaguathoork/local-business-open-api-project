locals {
  apps_subnets_to_create = {
        for key, value in var.apps_data :
    key => {
        name = value.name
        address_prefixes = value.address_prefixes
        delegated = value.delegated
    }
  }
}

locals {
  keyvault_subnet_to_create = {
    keyvault = {
        name = "keyvault"
        address_prefixes = [ "10.0.101.0/24" ]
        delegated = false
    }
  }
}

locals {
  subnets_to_create = merge(local.apps_subnets_to_create, local.keyvault_subnet_to_create)
}

locals {
  app_subnets = {
    for key, value in module.vnet.subnets :
    key => {
        id = value.id
    }
    if value.name != "keyvault"
  }
}

locals {
  keyvault_subnet = {
    for key, value in module.vnet.subnets :
    key => {
        id = values(value.id)
        name = value.name
        resource_group_name = values(value.resource_group_name)
    }
    if value.name == "keyvault"
  }
}

locals {
  apps = {
    for key, value in var.apps_data :
    key => {
        name = value.name
        os_type = value.os_type
        sku_name = value.sku_name
        kv_ip = value.kv_ip
    }
  }
}

locals {
  keyvaults = {
    for key, value in var.apps_data :
    key => {
        name = value.name
        sku_name = "standard"
        kv_ip = value.kv_ip
        # access_policies = {
            # object = {
            #   key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
            # },
            # principal = {
            #   key_permissions = ["Get", "WrapKey", "UnwrapKey"]
            # }
        # }
    }
  }
}