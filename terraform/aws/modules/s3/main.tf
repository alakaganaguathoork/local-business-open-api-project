resource "aws_s3_bucket" "eb_bucket" {
  bucket = var.eb_s3_bucket
}

resource "aws_s3_object" "eb_sample_app" {
  bucket = aws_s3_bucket.eb_bucket.id
  key    = "hello-world.zip"
  source = "https://s3.amazonaws.com/elasticbeanstalk-samples/hello-world.zip"
  etag   = filemd5("hello-world.zip")
}