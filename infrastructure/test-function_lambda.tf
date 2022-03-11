
resource "aws_lambda_function" "test-function_function" {
  function_name = var.test-function_function_name

  s3_bucket = aws_s3_bucket.lambda_archive_and_upload.id
  s3_key    = aws_s3_bucket_object.test-function_lambda.key

  runtime = "nodejs14.x"
  handler = var.test-function_function_handler

  source_code_hash = filemd5("../build/test-function.zip")

  role = aws_iam_role.test-function_role.arn

  timeout     = var.test-function_function_timeout_seconds
  memory_size = var.test-function_function_memory_size_mb

  environment {
    variables = {
      "SPROCKET_AWS_REGION" = "${var.aws_region}"
    }
  }

}

resource "aws_cloudwatch_log_group" "test-function" {
  name              = "/aws/lambda/${aws_lambda_function.test-function_function.function_name}"
  retention_in_days = var.default_log_retention_days
}

resource "aws_iam_role" "test-function_role" {
  name = "${var.test-function_function_name}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  inline_policy {
    name = "test-function_inline_policy"

    policy = jsonencode({
      Version : "2012-10-17"
      Statement = [
        {
          Effect : "Allow",
          Action : [
            "dynamodb:Query"
          ],
          Resource : [
            "*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "test-function_policy_attachment_basic" {
  role       = aws_iam_role.test-function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Variables
#####################################
variable "test-function_function_name" { type = string } # default="test-function"

variable "test-function_function_handler" { type = string } # default="test-function.handler"

variable "test-function_function_timeout_seconds" { type = string } # default=60

variable "test-function_function_memory_size_mb" { type = string } # default=128