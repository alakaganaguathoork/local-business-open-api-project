resource "azurerm_service_plan" "service_plan" {
  name                = "${var.environment}-${var.name}-service-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = lower(var.os_type) == "linux" ? "Linux" : "Windows"
  sku_name            = var.sku_name
}

resource "azurerm_linux_web_app" "linux_app" {
  count = lower(var.os_type) == "linux" ? 1 : 0

  name                          = "${var.name}-${var.location}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  https_only                    = true
  public_network_access_enabled = false
  service_plan_id               = azurerm_service_plan.service_plan.id
  virtual_network_subnet_id     = var.subnet_id

  site_config {
    always_on = false
    application_stack {
      docker_image_name   = var.docker_image
      docker_registry_url = "https://hub.docker.com"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_windows_web_app" "win_app" {
  count = lower(var.os_type) == "windows" ? 1 : 0

  name                          = "${var.name}-${var.location}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  https_only                    = true
  public_network_access_enabled = false
  service_plan_id               = azurerm_service_plan.service_plan.id
  virtual_network_subnet_id     = var.subnet_id

  site_config {
    always_on = false
    application_stack {
      docker_image_name   = var.docker_image
      docker_registry_url = "https://hub.docker.com"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}