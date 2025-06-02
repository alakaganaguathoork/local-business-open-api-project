resource "random_string" "random" {
  length = 3
}

resource "azurerm_storage_account" "sa" {
  name                     = lower("main${var.environment}${random_string.random.result}")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_private_endpoint" "private" {
  name                = "${azurerm_storage_account.sa.name}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  ip_configuration {
    name               = "${azurerm_storage_account.sa.name}-ip"
    private_ip_address = "10.0.200.10/32"
    subresource_name   = "blob"
    member_name        = "blob"
  }
  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}


resource "azurerm_private_dns_zone" "private_dns" {
  name                = "privatelink.blob.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
  name                  = "dns-vnet-link-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "a" {
  name                = lower(azurerm_storage_account.sa.name)
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 3000
  records             = [split("/", azurerm_private_endpoint.private.ip_configuration[0].private_ip_address)[0]]
}


# Container
resource "azurerm_storage_container" "main" {
  name               = "test"
  storage_account_id = azurerm_storage_account.sa.id
}

#Blob
resource "azurerm_storage_blob" "test_html" {
  name                   = "test.html"
  type                   = "Block"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.main.name
  source_content         = <<EOF
    <hmtl>
        <head>
            <title>TEST</title>
        </head>
        <body>
            TEST
        </body
    </html>
  EOF
}