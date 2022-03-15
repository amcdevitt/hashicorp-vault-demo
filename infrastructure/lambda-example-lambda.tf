
resource "aws_lambda_function" "example-lambda_function" {
  function_name = var.example-lambda_function_name

  s3_bucket = aws_s3_bucket.lambda_archive_and_upload.id
  s3_key    = aws_s3_object.example-lambda_lambda.key

  runtime = "nodejs14.x"
  handler = var.example-lambda_function_handler

  source_code_hash = filebase64sha256("../build/example-lambda.zip")

  role = aws_iam_role.example-lambda_role.arn

  timeout     = var.example-lambda_function_timeout_seconds
  memory_size = var.example-lambda_function_memory_size_mb

  environment {
    variables = {
      "SPROCKET_AWS_REGION" = "${var.aws_region}"
    }
  }

}

resource "aws_cloudwatch_log_group" "example-lambda" {
  name              = "/aws/lambda/${aws_lambda_function.example-lambda_function.function_name}"
  retention_in_days = var.default_log_retention_days
}

resource "aws_iam_role" "example-lambda_role" {
  name = "${var.example-lambda_function_name}_role"

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
    name = "example-lambda_inline_policy"

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

resource "aws_iam_role_policy_attachment" "example-lambda_policy_attachment_basic" {
  role       = aws_iam_role.example-lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Variables
#####################################
variable "example-lambda_function_name" { type = string } # default="vlt-example-lambda"

variable "example-lambda_function_handler" { type = string } # default="example-lambda.handler"

variable "example-lambda_function_timeout_seconds" { type = string } # default=60

variable "example-lambda_function_memory_size_mb" { type = string } # default=128