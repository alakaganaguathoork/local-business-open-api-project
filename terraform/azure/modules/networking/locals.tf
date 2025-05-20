locals {
  instances_networking = {
    for key, app in var.instances :
    key => {
        location = app.location
        subnet = [ app.subnet ]
    }
  } 
}