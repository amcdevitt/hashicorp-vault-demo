
resource "aws_s3_object" "request-router_lambda" {
  bucket = aws_s3_bucket.lambda_archive_and_upload.id

  key    = "lambda/request-router.zip"
  source = "../build/request-router.zip"

  etag = filemd5("../build/request-router.zip")
  tags = {
    Hash    = filemd5("../build/request-router.zip")
    Purpose = var.global_tag_purpose
  }
}

resource "aws_s3_object" "vault_test_lambda" {
  bucket = aws_s3_bucket.lambda_archive_and_upload.id

  key    = "lambda/vault_test.zip"
  source = "../build/vault_test.zip"

  etag = filemd5("../build/vault_test.zip")
  tags = {
    Hash    = filemd5("../build/vault_test.zip")
    Purpose = var.global_tag_purpose
  }
}

resource "aws_s3_object" "example-lambda_lambda" {
  bucket = aws_s3_bucket.lambda_archive_and_upload.id

  key    = "lambda/example-lambda.zip"
  source = "../build/example-lambda.zip"

  etag = filemd5("../build/example-lambda.zip")
  tags = {
    Hash    = filemd5("../build/example-lambda.zip")
    Purpose = var.global_tag_purpose
  }
}

