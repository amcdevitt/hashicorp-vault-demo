
resource "aws_lambda_function" "anotherFunction_function" {
  function_name = var.anotherFunction_function_name

  s3_bucket = aws_s3_bucket.lambda_archive_and_upload.id
  s3_key    = aws_s3_object.anotherFunction_lambda.key

  runtime = "nodejs14.x"
  handler = var.anotherFunction_function_handler

  source_code_hash = filebase64sha256("../build/anotherFunction.zip")

  role = aws_iam_role.anotherFunction_role.arn

  timeout     = var.anotherFunction_function_timeout_seconds
  memory_size = var.anotherFunction_function_memory_size_mb

  environment {
    variables = {
      "SPROCKET_AWS_REGION" = "${var.aws_region}"
    }
  }

}

resource "aws_cloudwatch_log_group" "anotherFunction" {
  name              = "/aws/lambda/${aws_lambda_function.anotherFunction_function.function_name}"
  retention_in_days = var.default_log_retention_days
}

resource "aws_iam_role" "anotherFunction_role" {
  name = "${var.anotherFunction_function_name}_role"

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
    name = "anotherFunction_inline_policy"

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

resource "aws_iam_role_policy_attachment" "anotherFunction_policy_attachment_basic" {
  role       = aws_iam_role.anotherFunction_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Variables
#####################################
variable "anotherFunction_function_name" { type = string } # default="vlt-anotherFunction"

variable "anotherFunction_function_handler" { type = string } # default="anotherFunction.handler"

variable "anotherFunction_function_timeout_seconds" { type = string } # default=60

variable "anotherFunction_function_memory_size_mb" { type = string } # default=128