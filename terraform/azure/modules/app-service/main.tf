resource "random_string" "random" {
  for_each = local.apps

  length = 7
  numeric = true
  special = false  
}

resource "azurerm_resource_group" "resource_group" {
  for_each = {
    for idx, app in local.apps : idx => app
  }

  name     = each.value.environment
  location = each.value.location
}

resource "azurerm_service_plan" "service_plan" {
  for_each = local.apps

  name = "${each.value.environment}-${random_string.random[each.key].result}"
  resource_group_name = azurerm_resource_group.resource_group[each.key].name
  location = azurerm_resource_group.resource_group[each.key].location
  os_type = lower(each.value.os_type) == "linux" ? "Linux" : "Windows"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "linux_app" {
  for_each = local.linux_apps
  
  name = "${each.key}-${random_string.random[each.key].result}" 
  resource_group_name = azurerm_resource_group.resource_group[each.key].name
  location = azurerm_resource_group.resource_group[each.key].location
  service_plan_id = azurerm_service_plan.service_plan[each.key].id
  # zip_deploy_file = "../../local-business.zip"

    site_config {    
    always_on = false
    # dynamic "ip_restriction" {
      # for_each = {
        # for idx, ip in each.value.allowed_ips :
        # ip => idx
      # }
      # content {
        # name       = "Allow ${ip_restriction.key}"
        # ip_address = ip_restriction.key
        # priority   = 100 + ip_restriction.value
        # action     = "Allow"
      # }
    # }
  }
  
  https_only = true
  public_network_access_enabled = false
}

resource "azurerm_windows_web_app" "win_app" {
  for_each = local.windows_apps

  name = "${each.value.name}-${random_string.random[each.key].result}" 
  resource_group_name = azurerm_resource_group.resource_group[each.key].name
  location = azurerm_resource_group.resource_group[each.key].location
  service_plan_id = azurerm_service_plan.service_plan[each.key].id
  # zip_deploy_file = "${path.root}/local-business.zip"

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
        action     = "Deny"
      }
    }
  }
  
  https_only = true
  public_network_access_enabled = false
}