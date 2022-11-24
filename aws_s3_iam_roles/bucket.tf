resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_s3_bucket" "example" {
  bucket = "example-${random_string.suffix.result}"
}

output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
