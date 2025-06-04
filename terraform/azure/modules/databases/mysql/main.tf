resource "azurerm_mssql_server" "server" {
  name                         = "${var.environment}-${var.name}-sqlserver"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
  public_network_access_enabled = false
}

resource "azurerm_private_dns_zone" "private_dns" {
  name                = "${var.name}.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
  name                  = "${var.environment}-${var.name}-dns-to-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "a" {
  name                = lower(var.name)
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 3000
  records             = [split("/", var.private_ip)[0]]
}

resource "azurerm_mssql_database" "db" {
  name           = "${var.environment}-${var.name}-db"
  server_id      = azurerm_mssql_server.server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  # read_scale     = true # Not available for "Basic" SKU
  sku_name       = "Basic"
  # zone_redundant = true # Not available for "Basic" SKU
  enclave_type   = "VBS"
  storage_account_type = "Local"
  # maintenance_configuration_name = "SQL_NorthEurope_DB_1" # Not available for this setup
  # transparent_data_encryption_key_vault_key_id = var.keyvault_id

  tags = {
    environment = var.environment
    location    = var.location
    company     = var.company
  }

#   identity { # No User identity is used for now
    # type         = "UserAssigned"
    # identity_ids = [azurerm_user_assigned_identity.example.id]
#   }

  # prevent the possibility of accidental data loss skipped for this setup
}