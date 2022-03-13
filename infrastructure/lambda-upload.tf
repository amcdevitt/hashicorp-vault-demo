
resource "aws_s3_bucket_object" "exampleFunction_lambda" {
  bucket = aws_s3_bucket.lambda_archive_and_upload.id

  key    = "lambda/exampleFunction.zip"
  source = "../build/exampleFunction.zip"

  etag = filemd5("../build/exampleFunction.zip")
  tags = {
    Purpose = var.global_tag_purpose
  }
}

resource "aws_s3_bucket_object" "anotherFunction_lambda" {
  bucket = aws_s3_bucket.lambda_archive_and_upload.id

  key    = "lambda/anotherFunction.zip"
  source = "../build/anotherFunction.zip"

  etag = filemd5("../build/anotherFunction.zip")
  tags = {
    Purpose = var.global_tag_purpose
  }
}

