terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">3.0.0"
    }
  }
}

data "aws_ecr_authorization_token" "token" {}

provider "aws" {
  region = var.region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password  = data.aws_ecr_authorization_token.token.password
  }
}