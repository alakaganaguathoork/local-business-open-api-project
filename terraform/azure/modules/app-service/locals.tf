locals {
  apps = var.apps
}

locals {
  environment = var.environment
}

locals {
  location = var.location
}

locals {
  linux_apps = {
    for key, value in var.apps :
    key => value
    if lower(value.os_type) == "linux"
  }
}

locals {
  windows_apps = {
    for key, value in var.apps :
    key => value
    if lower(value.os_type) == "windows"
  }
}

locals {
  subnets = var.subnets
}