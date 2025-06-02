# resource "azurerm_dns_zone" "public" {
  # name = var.private_dns_zone_name
  # resource_group_name = var.resource_group_name
# }

resource "azurerm_private_dns_zone" "private_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
  name                  = "dns-vnet-link-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "a" {
  for_each = var.records_a

  name                = lower(each.value.name)
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 3000
  records             = [split("/", each.value.record)[0]]
}
