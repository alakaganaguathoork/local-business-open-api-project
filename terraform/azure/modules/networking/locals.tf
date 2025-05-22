locals {
  environment = var.environment
}

locals {
  location = var.location
}

# locals {
  # networking_params = {
    # for key, app in var.instances : 
    # key => {
      # networking = {
        # subnet = app.networking.subnet,
        # public_ip = app.networking.public_ip,
        # private_endpoint = app.networking.private_endpoint,
        # delegated = app.networking.delegated,
      # }
    # }
  # }
# }
# 
# locals {
  # instances_with_public_ip = {
    # for key, value in var.instances : 
    # key => value
    # if value.networking.public_ip
  # }
# }

