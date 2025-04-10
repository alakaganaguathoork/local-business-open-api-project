resource "random_string" "random" {
  for_each = var.apps

  length = 7
  numeric = true
  special = false
}

resource "azurerm_resource_group" "resource_group" {
  for_each = var.apps

  name     = "${each.value.resource_group_name}-${each.value.environment}"
  location = each.value.location
}

resource "azurerm_service_plan" "service_plan" {
  for_each = var.apps

  name = "${each.value.service_plan_name}-${random_string.random[each.key].result}"
  resource_group_name = azurerm_resource_group.resource_group[each.key].name
  location = azurerm_resource_group.resource_group[each.key].location
  os_type = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "app" {
  for_each = var.apps

  name = "${each.value.name}-${random_string.random[each.key].result}" 
  resource_group_name = azurerm_resource_group.resource_group[each.key].name
  location = azurerm_resource_group.resource_group[each.key].location
  service_plan_id = azurerm_service_plan.service_plan[each.key].id
  # zip_deploy_file = "../../local-business.zip"

    site_config {    
    always_on = false
    dynamic "ip_restriction" {
      for_each = {
        for idx, ip in each.value.allowed_ips :
        ip => idx
      }
      content {
        name       = "Allow ${ip_restriction.key}"
        ip_address = ip_restriction.key
        priority   = 100 + ip_restriction.value
        action     = "Allow"
      }
    }
  }
  
  https_only = true
  public_network_access_enabled = true
}