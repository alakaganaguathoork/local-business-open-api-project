resource "aws_s3_bucket" "public" {
  bucket = "${var.environment}-${var.region}-public"
  force_destroy = true

  tags   = {
    Name = "s3-buckets-${var.environment}"
  }
}

# Just for a reference - ACLs are disabled by default, so no need to create this resource 
# resource "aws_s3_bucket_ownership_controls" "disabled" {
#   bucket = aws_s3_bucket.public.id
# 
#   rule {
    # object_ownership = "BucketOwnerEnforced"
#   }
# }

resource "aws_s3_bucket_public_access_block" "enable" {
  bucket = aws_s3_bucket.public.id
  block_public_acls = false
  ignore_public_acls = false
  block_public_policy = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "name" {
  bucket = aws_s3_bucket.public.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.public.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.public.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "test-csv" {
  bucket = aws_s3_bucket.public.id
  key = "test.csv"
  content = file("files/test.csv")
  content_type = "application/csv"
  # acl = "public-read"
}

output "test-csv-url" {
  value = "https://${aws_s3_bucket.public.bucket}.s3.${var.region}.amazonaws.com/${aws_s3_object.test-csv.key}"
}