# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html#security-group-restricting-cluster-traffic
module "security_groups" {
  source = "git::https://github.com/alakaganaguathoork/local-business-open-api-project.git//terraform/aws/modules/vpc/security-group?ref=main"

  vpc_id = aws_vpc.main.id
  security_groups = var.security_groups
}