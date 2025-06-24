resource "aws_prometheus_workspace" "main" {
  alias = "main"

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_prometheus_workspace_configuration" "example" {
  workspace_id = aws_prometheus_workspace.main.id

  limits_per_label_set {
    label_set = {}
    limits {
      max_series = 50000
    }
  }
}

resource "aws_prometheus_scraper" "main" {
  destination {
    amp {
      workspace_arn = aws_prometheus_workspace.main.arn
    }
  }

  scrape_configuration = templatefile("${path.root}/prometheus.yml", {
    jobs = var.scrape_jobs
  }) 
  }