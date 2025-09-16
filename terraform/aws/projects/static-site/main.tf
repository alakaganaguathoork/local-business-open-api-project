terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.13.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.env
    }
  }
}

###
## Variables
###
variable "region" {
  type = string
  description = "Region for provisioned resources"
}

variable "env" {
  type = string
}

variable "domain_name" {
  type = string
  description = "Name of the domain"
}

variable "bucket_name" {
  type = string
  description = "Name of the bucket"
}

###
## Resources
###
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name = "Main"
  }
}

# Bucket ACL
resource "aws_s3_bucket_acl" "main-acl" {
  bucket = aws_s3_bucket.main.id
  acl = "public-read"
  depends_on = [ aws_s3_bucket_ownership_controls.bucket-ownership ]
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Access & policy
resource "aws_s3_bucket_ownership_controls" "bucket-ownership" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [ aws_s3_bucket_public_access_block.public-access ]
}

resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket = aws_s3_bucket.main.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.iam-policy-1.json
}

data "aws_iam_policy_document" "iam-policy-1" {
  statement {
    sid = "AllowPublicRead"
    effect = "Allow"

    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]
    actions = [ "s3:GetObject" ]

    principals {
      type = "*"
      identifiers = [ "*" ]
    }
  }

  depends_on = [ aws_s3_bucket_public_access_block.public-access ]
}

# Website config
resource "aws_s3_bucket_website_configuration" "website-config" {
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# Website object upload
resource "aws_s3_object" "index-html" {
  for_each = fileset("site-files/", "*.html")

  bucket = aws_s3_bucket.main.id
  key = each.value
  source = "site-files/${each.value}"
  content_type = "text/html"
  etag = filemd5("site-files/${each.value}")
  acl = "public-read"
}

resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "www.${var.domain_name}"
    Description = var.domain_name
  }

  comment = var.domain_name
}

resource "aws_route53_record" "www-a" {
  zone_id = aws_route53_zone.main.id
  name = "www.${var.domain_name}"
  type = "A"

  alias {
    name = aws_s3_bucket_website_configuration.website-config.website_endpoint
    # hardcode taken from https://docs.aws.amazon.com/general/latest/gr/s3.html#s3_website_region_endpoints
    zone_id = "Z3AQBSTGFYJSTF"
    evaluate_target_health = false
  }
}

###
## Outputs
###
output "website-endpoint" {
  value = aws_s3_bucket_website_configuration.website-config.website_endpoint
}