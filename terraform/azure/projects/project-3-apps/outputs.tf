output "resource_group" {
  value = module.resource_group.env
}

output "subnets" {
  value = {
    for value in module.subnets :
    value.subnet.name => value.subnet
  }
}

output "app_ids" {
  value = {
    for key, value in module.apps :
    key => {
      id = value.app_id
    }
  }
}

output "keyvaults_uri" {
  value = {
    for value in module.keyvaults :
    value.keyvault.name => value.keyvault.vault_uri
  }
}

output "apps_identity" {
  value = {
    for value in module.apps :
    value.app.name => value.app.identity
  }
  sensitive = true
}

output "nsg_custom_rules" {
  value = module.network_security_groups
}