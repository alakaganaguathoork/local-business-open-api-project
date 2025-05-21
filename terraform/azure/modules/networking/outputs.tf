output "subnets" {
  value = azurerm_subnet.subnets 
}

output "resource_groups" {
  value = azurerm_resource_group.vnet_rg
}