resource "azurerm_network_security_group" "ns_group" {
  name                = "${var.environment}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "custom_rules" {
  for_each = { for value in var.custom_rules : value.name => value }

  name                        = each.value.name
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.ns_group.name

  # description                = lookup(each.value, "description", "Security rule for ${lookup(each.value, "name", "default_rule_name")}")
  # destination_address_prefix = lookup(each.value, "destination_application_security_group_ids", null) == null && lookup(each.value, "destination_address_prefixes", null) == null ? lookup(each.value, "destination_address_prefix", "*") : null

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

resource "azurerm_subnet_network_security_group_association" "subnet_assoc" {
  # for_each = var.subnets

  subnet_id                 = var.subnets["keyvault"].subnet.id
  network_security_group_id = azurerm_network_security_group.ns_group.id
}