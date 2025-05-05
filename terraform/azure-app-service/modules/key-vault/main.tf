data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keyvault_rg" {
  name = "keyvault"
  location = var.location

}

resource "azurerm_key_vault" "local_kv" {
  name = "local"
  tenant_id = data.azurerm_client_config.current.tenant_id
  resource_group_name = azurerm_resource_group.keyvault_rg.name
  location = azurerm_resource_group.keyvault_rg.location
  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.local_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_key" "random_password" {
  name         = "random-test-password"
  key_vault_id = azurerm_key_vault.local_kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "unwrapKey",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

resource "azurerm_key_vault_secret" "secret_sauce" {
  name         = "secret-sauce"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.local_kv.id
}