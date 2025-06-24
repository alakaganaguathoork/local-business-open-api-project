module "vpc" {
  source = "../../modules/networking"

  vpc_cidr  = ["10.0.0.0/16"]
  public_subnets = ["", ""]
}