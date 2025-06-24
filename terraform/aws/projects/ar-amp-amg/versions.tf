terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">=3.0.0"
      configuration_aliases = [ docker.main ]
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  alias = "main"
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password  = data.aws_ecr_authorization_token.token.password
  }
}
