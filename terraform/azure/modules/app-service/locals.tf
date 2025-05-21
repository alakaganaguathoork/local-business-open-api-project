locals {
  apps = var.instances
}

locals {
  environment = var.environment
}

locals {
  location = var.location
}

locals {
  linux_apps = {
    for k, v in var.instances : k => v if lower(v.os_type) == "linux"
  }
}

locals {
  windows_apps = {
    for k, v in var.instances : k => v if lower(v.os_type) == "windows"
  }
}

locals {
  subnets = var.subnets
}