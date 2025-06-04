locals {
  delegation = {
    app = "Microsoft.Web/serverFarms"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.environment}-${var.subnet.name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet.address_prefixes
  service_endpoints    = try(var.subnet.service_endpoints, [])

  private_endpoint_network_policies = var.subnet.enable_private_endpoint_network_policies ? "Enabled" : null

  dynamic "delegation" {
    for_each = var.subnet.delegation != "" ? [var.subnet.delegation] : []
    content {
      name = "delegation"
      service_delegation {
        name = lookup(local.delegation, delegation.value)
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}