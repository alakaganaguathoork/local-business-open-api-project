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

provider "aws" {
  region = var.region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}