module "prometheus" {
  source = "../../modules/prometheus"

  scrape_jobs = ["local-business"]
}