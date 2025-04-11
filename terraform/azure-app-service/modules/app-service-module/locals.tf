locals {
  linux_apps = {
    for k, v in var.apps : k => v if lower(v.os_type) == "linux"
  }
}

locals {
  windows_apps = {
    for k, v in var.apps : k => v if lower(v.os_type) == "windows"
  }
}