output "subnets" {
  value = {
    for key, subnet in azurerm_subnet.subnets : 
    key => subnet.id
  }
}