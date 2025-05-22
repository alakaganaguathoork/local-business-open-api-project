data "azurerm_client_config" "current" {
  
}

resource "random_string" "random" {
  length = 7
  numeric = true
  special = false  
}

resource "azurerm_resource_group" "kv" {
  name = "keyvaultRG-${var.environment}"
  location = var.location
}

resource "azurerm_user_assigned_identity" "iam" {
  name                = "iam-admin-${var.environment}"
  location            = azurerm_resource_group.kv.location
  resource_group_name = azurerm_resource_group.kv.name
}

resource "azurerm_key_vault" "main_kv" {
  name                        = "keyvault-${random_string.random.result}-${var.environment}"
  location                    = azurerm_resource_group.kv.location
  resource_group_name         = azurerm_resource_group.kv.name
  enabled_for_disk_encryption = true
  tenant_id                   = azurerm_user_assigned_identity.iam.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.iam.tenant_id
    object_id = azurerm_user_assigned_identity.iam.principal_id

    key_permissions = ["Get", "WrapKey", "UnwrapKey"]
  }
}

resource "azurerm_key_vault_key" "mysql" {
  depends_on = [azurerm_key_vault.main_kv]

  name         = "mysql-key--${var.environment}"
  key_vault_id = azurerm_key_vault.main_kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["unwrapKey", "wrapKey"]
}