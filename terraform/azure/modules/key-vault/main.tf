data "azurerm_client_config" "current" {

}

resource "random_string" "random" {
  length  = 3
  numeric = true
  special = false
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.environment}-${var.name}-${random_string.random.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = lower(var.sku_name)

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = [var.my_ip]
  }
}

resource "azurerm_private_endpoint" "private" {
  name                = "${azurerm_key_vault.kv.name}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  ip_configuration {
    name               = "${azurerm_key_vault.kv.name}-ip"
    private_ip_address = var.private_ip
    subresource_name   = "vault"
    member_name        = "default"
  }
  private_service_connection {
    name                           = "${azurerm_key_vault.kv.name}-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}