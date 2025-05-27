output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "subnets" {
  value = azurerm_subnet.subnets
}

output "subnets_address_prefixes" {
  value = {
    for key, subnet in azurerm_subnet.subnets :
    key => subnet.address_prefixes
  }
}