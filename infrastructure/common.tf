
# Archive and upload lambda package

resource "aws_s3_bucket" "lambda_archive_and_upload" {
  bucket        = var.upload_s3_bucket
  force_destroy = true
}
