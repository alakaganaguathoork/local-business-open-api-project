resource "azurerm_resource_group" "nsg_rg" {
  name     = "nsgRG"
  location = var.location
}

resource "azurerm_network_security_group" "ns_group" {
  name                = "${var.environment}-nsg"
  location            = azurerm_resource_group.nsg_rg.location
  resource_group_name = azurerm_resource_group.nsg_rg.name
}

resource "azurerm_network_security_rule" "advanced_rules" {
  for_each = var.nsg_rules

  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  resource_group_name         = azurerm_resource_group.nsg_rg.name
  network_security_group_name = azurerm_network_security_group.ns_group.name

  source_port_range       = try(each.value.source_port_range, null)
  source_port_ranges      = try(each.value.source_port_ranges, null)
  destination_port_range  = try(each.value.destination_port_range, null)
  destination_port_ranges = try(each.value.destination_port_ranges, null)

  source_address_prefix        = try(each.value.source_address_prefix, null)
  source_address_prefixes      = try(each.value.source_address_prefixes, null)
  destination_address_prefix   = try(each.value.destination_address_prefix, null)
  destination_address_prefixes = try(each.value.destination_address_prefixes, null)

  source_application_security_group_ids      = try(each.value.source_application_security_group_ids, null)
  destination_application_security_group_ids = try(each.value.destination_application_security_group_ids, null)
}