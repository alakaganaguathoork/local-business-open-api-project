locals {
  environment = var.environment
}

locals {
  location = var.location
}

locals {
  subnets = {
    for key, app in var.instances : 
    key => {
      subnet = [ app.subnet ],
      delegated = app.delegated
    }
  }
}