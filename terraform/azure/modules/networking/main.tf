resource "azurerm_resource_group" "vnet_rg" {
  name = "${var.environment}"
  location = "northeurope"
}

resource "azurerm_resource_group" "networking_rg" {
  for_each = local.instances_networking

  name     = "${each.value.location}-${var.environment}"
  location = each.value.location
}

resource "azurerm_virtual_network" "vnet" {
  name = "${var.environment}"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location = azurerm_resource_group.vnet_rg.location
  address_space = [ "172.16.0.0/16" ]
}

resource "azurerm_subnet" "subnets" {
  for_each = local.instances_networking
  name = "${each.value.location}-${var.environment}"
  resource_group_name = azurerm_resource_group.networking_rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = each.value.subnet

#   private_endpoint_network_policies = each.value.private_endpoint ? "Enabled" : null
#   
#   dynamic "delegation" {
    # for_each = each.value.delegated ? [1] : []
    # content {
    #   name = "delegation"
    #   service_delegation {
        # name = "Microsoft.Web/serverFarms"
    #   }
    # } 
#   }
}