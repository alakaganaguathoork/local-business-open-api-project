locals {
  linux_apps = {
    for key, value in var.apps :
    key => merge(
      value,
      { subnet = var.subnets[key] }
    )
    if lower(value.os_type) == "linux"
  }
}

locals {
  windows_apps = {
    for key, value in var.apps :
    key => merge(
      value,
      { subnet = var.subnets[key] }
    )
    if lower(value.os_type) == "windows"
  }
}

locals {
  apps = {
    for key, value in merge(local.linux_apps, local.windows_apps) :
    key => value
  }
}