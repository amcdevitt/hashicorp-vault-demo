
resource "aws_s3_object" "exampleFunction_lambda" {
  bucket = aws_s3_bucket.lambda_archive_and_upload.id

  key    = "lambda/exampleFunction.zip"
  source = "../build/exampleFunction.zip"

  etag = filemd5("../build/exampleFunction.zip")
  tags = {
    Hash    = filemd5("../build/exampleFunction.zip")
    Purpose = var.global_tag_purpose
  }
}

resource "aws_s3_object" "anotherFunction_lambda" {
  bucket = aws_s3_bucket.lambda_archive_and_upload.id

  key    = "lambda/anotherFunction.zip"
  source = "../build/anotherFunction.zip"

  etag = filemd5("../build/anotherFunction.zip")
  tags = {
    Hash    = filemd5("../build/anotherFunction.zip")
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

