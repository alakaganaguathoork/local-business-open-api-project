module "helm_releases" {
  source = "./modules/helm_release"

  depends_on = [module.ingress]
}
