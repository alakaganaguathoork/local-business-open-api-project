terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"
    }
  }
  cloud {
    organization = "alakaganaguathoork"
    workspaces {
      project = "Default Project"
      name = "sandbox"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "ManagedBy"   = "terraform"
      "Environment" = var.environment
    }
  }
}
