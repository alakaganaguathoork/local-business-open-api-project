locals {
  subnets = {
    for key, value in var.apps :
    key => {
      subnet_cidr = value.subnet_cidr
    }
  }
}