resource "random_string" "random" {
  for_each = var.subnets

  length = 7
  numeric = true
  special = false  
}

resource "azurerm_resource_group" "networking" {
  name = "vnetRG-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name = "vnet-${var.environment}"
  resource_group_name = azurerm_resource_group.networking.name
  location = azurerm_resource_group.networking.location
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name = "subnet-${each.key}-${var.environment}"
  resource_group_name = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = each.value.address_prefixes

  private_endpoint_network_policies = each.value.private_endpoint ? "Enabled" : null
  private_link_service_network_policies_enabled = false
  
  dynamic "delegation" {
    for_each = each.value.delegated ? [1] : []
    content {
      name = "delegation"
      service_delegation {
        name = "Microsoft.Web/serverFarms"
      }
    } 
  }
}

# resource "azurerm_public_ip" "public" {
  # for_each = {
    # for key, value in local.networking_params :
    # key => value
    # if value.networking.public_ip
  # }
# 
  # name                = "${each.key}-pip"
  # sku                 = "Standard"
  # resource_group_name = azurerm_resource_group.networking.name
  # location            = azurerm_resource_group.networking.location
  # allocation_method   = "Static"
# }
# 
# resource "azurerm_lb" "lb" {
  # for_each = local.networking_params
# 
  # name                = "mainLB"
  # sku                 = "Standard"
  # resource_group_name = azurerm_resource_group.networking.name
  # location            = azurerm_resource_group.networking.location
# 
  # frontend_ip_configuration {
    # name                 = azurerm_public_ip.public[each.key].name
    # public_ip_address_id = azurerm_public_ip.public[each.key].id
  # }
# }
# 
# resource "azurerm_private_link_service" "private_ls" {
  # for_each = local.networking_params
# 
  # name                = "${each.key}-privatelink"
  # resource_group_name = azurerm_resource_group.networking.name
  # location            = azurerm_resource_group.networking.location
  # 
  # nat_ip_configuration {
    # name      = azurerm_public_ip.public[each.key].name
    # primary   = true
    # subnet_id = azurerm_subnet.subnet[each.key].id
  # }
# 
  # load_balancer_frontend_ip_configuration_ids = [
    # azurerm_lb.lb[each.key].frontend_ip_configuration[0].id,
  # ]
# 
  # depends_on = [ azurerm_lb.lb ]
# }
# 
# resource "azurerm_private_endpoint" "private" {
  # for_each = local.networking_params
# 
  # name                = "${each.key}-endpoint"
  # location            = azurerm_resource_group.networking.location
  # resource_group_name = azurerm_resource_group.networking.name
  # subnet_id           = azurerm_subnet.subnet[each.key].id
# 
  # private_service_connection {
    # name                           = "${each.key}-privateserviceconnection"
    # private_connection_resource_id = azurerm_private_link_service.private_ls[each.key].id
    # is_manual_connection           = false
  # }
# 
  # depends_on = [ azurerm_private_link_service.private_ls ]
# }