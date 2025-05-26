resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = var.vnet.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dsn_vnet_link" {
  name                  = "dns-vnet-link-${var.environment}"
  resource_group_name   = var.vnet.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = var.vnet.id
}

resource "azurerm_private_dns_a_record" "kv_pdar" {
  for_each = var.dns_a_records

  name                = lower(each.value.name)
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = var.vnet.resource_group_name
  ttl                 = 3000
  records             = [each.value.ip_address]
}