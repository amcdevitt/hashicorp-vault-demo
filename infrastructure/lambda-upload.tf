
resource "aws_s3_bucket_object" "test-function_lambda" {
  bucket = aws_s3_bucket.lambda_archive_and_upload.id

  key    = "lambda/test-function.zip"
  source = "../build/test-function.zip"

  etag = filemd5("../build/test-function.zip")
  tags = {
    Purpose = var.global_tag_purpose
  }
}

