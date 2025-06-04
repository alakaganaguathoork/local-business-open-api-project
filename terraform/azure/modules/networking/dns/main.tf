#
# Possible zone_name values:
# Key Vault:  *.vaultcore.azure.net
# Storage:    *.storage.azure.com"
#
resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "${var.environment}-dns-${var.zone_name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = var.vnet_id
}

# resource "azurerm_private_dns_a_record" "a" {
  # for_each = var.records_a
# 
  # name                = lower(each.value.name)
  # zone_name           = azurerm_private_dns_zone.private_dns[0].name
  # resource_group_name = var.resource_group_name
  # ttl                 = 3000
  # records             = [split("/", each.value.record)[0]]
# }
