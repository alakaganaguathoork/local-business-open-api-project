# General
locals {
  environment = "test"
  location    = "northeurope"
  company     = "mishap"
  service_types = {
    app      = "app"
    keyvault = "keyvault"
  }
  os_type = {
    linux   = "linux"
    windows = "windows"
  }
}

# Apps variables
locals {
  app = {
    service_type = local.service_types.app
    sku_name     = "B1"
  }
}

# App names
locals {
  app_names = {
    local   = "local-business"
    random  = "random-skoobie"
    windows = "windows-bill"
  }
}

# Keyvault locals
locals {
  keyvault = {
    service_type = local.service_types.keyvault
    name         = "keyvault"
    sku_name     = "standard"
  }
}

# Networking
locals {
  vpc_cidr = "10.0.0.0/16"

  subnets = {
    for_apps = {
      (local.app_names.local) = {
        service_type = local.app.service_type
        name         = local.app_names.local
        delegated    = true
      },
      (local.app_names.random) = {
        service_type = local.app.service_type
        name         = local.app_names.random
        delegated    = true
      },
      (local.app_names.windows) = {
        service_type = local.app.service_type
        name         = local.app_names.windows
        delegated    = true
      }
    },
    for_keyvault = {
      keyvault = {
        service_type = local.keyvault.service_type
        name         = local.keyvault.name
        private      = true
      },
    }
  }
}

# Network Security Rules map of objects
locals {
  nsg_rules = {

    vnet_inbound_all = {
      name                       = "vnet-inbound-all"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "10.0.0.0/16"
      source_port_range          = "*"
      destination_port_range     = "*"
      destination_address_prefix = "10.0.0.0/16"
    }

    # keyvault_allow_private_link = {
      # name                        = "AllowPrivateLinkToKeyVault"
      # priority                    = 200
      # direction                   = "Inbound"
      # access                      = "Allow"
      # protocol                    = "*"
      # source_address_prefix       = local.subnets.for_keyvault.name
      # destination_address_prefix  = "*"
      # source_port_range           = "*"
      # destination_port_range      = "*"
    # }

    # ssh-all = {
    #   name                       = "ssh-all"
    #   priority                   = 100
    #   direction                  = "Inbound"
    #   access                     = "Allow"
    #   protocol                   = "Tcp"
    #   source_address_prefix      = "1.2.3.4/32"
    #   source_port_range          = "*"
    #   destination_port_range     = "22"
    #   source_address_prefix      = "VirtualNetwork"
    #   destination_address_prefix = "*"
    # }

    # http-https = {
    # name                       = "http-https"
    # priority                   = 102
    # direction                  = "Inbound"
    # access                     = "Allow"
    # protocol                   = "Tcp"
    # source_port_range          = "*"
    # destination_port_ranges    = [80,443]
    # source_address_prefixes    = ["1.2.3.4/32", "5.6.7.8/32"]
    # destination_address_prefix = "AzureLoadBalancer"
    # }
    #  
    # dns-tcp = {
    # name                       = "dns-tcp"
    # priority                   = 100
    # direction                  = "Outbound"
    # access                     = "Allow"
    # protocol                   = "Tcp"
    # source_port_range          = "*"
    # destination_port_range    = "53"
    # source_address_prefix      = "*"
    # destination_address_prefix = "*"
    # }
    #  
    # dns-udp = {
    # name                       = "dns-tcp"
    # priority                   = 101
    # direction                  = "Outbound"
    # access                     = "Allow"
    # protocol                   = "Udp"
    # source_port_range          = "*"
    # destination_port_range    = "53"
    # source_address_prefix      = "*"
    # destination_address_prefix = "*"
    # }
  }
}

# Allowed IPs
locals {
  allowed_ips = [
    "194.62.136.215/32",
    "194.62.136.216/32",
    "10.10.1.0/16"
  ]
}

# Apps constructed map of objects
locals {
  apps = {
    "local-business" = {
      name     = local.app_names.local
      os_type  = local.os_type.linux
      sku_name = local.app.sku_name
      subnet   = local.subnets.for_apps[local.app_names.local]
      keyvault = local.keyvault
    },
    "random-skoobie" = {
      name     = local.app_names.random
      os_type  = local.os_type.linux
      sku_name = local.app.sku_name
      subnet   = local.subnets.for_apps[local.app_names.random]
      keyvault = local.keyvault
    },
    "windows-bill" = {
      name     = local.app_names.windows
      os_type  = local.os_type.windows
      sku_name = local.app.sku_name
      subnet   = local.subnets.for_apps[local.app_names.windows]
      keyvault = local.keyvault
    },
  }
}

# Constructed map of objects with main data
locals {
  main = {
    keyvault_subnet = local.subnets.for_keyvault
    nsg_rules       = local.nsg_rules
    services = {
      apps = local.apps
    }
  }
}