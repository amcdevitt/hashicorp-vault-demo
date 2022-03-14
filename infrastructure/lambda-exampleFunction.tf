
resource "aws_lambda_function" "exampleFunction_function" {
  function_name = var.exampleFunction_function_name

  s3_bucket = aws_s3_bucket.lambda_archive_and_upload.id
  s3_key    = aws_s3_object.exampleFunction_lambda.key

  runtime = "nodejs14.x"
  handler = var.exampleFunction_function_handler

  source_code_hash = filebase64sha256("../build/exampleFunction.zip")

  role = aws_iam_role.exampleFunction_role.arn

  timeout     = var.exampleFunction_function_timeout_seconds
  memory_size = var.exampleFunction_function_memory_size_mb

  environment {
    variables = {
      "SPROCKET_AWS_REGION" = "${var.aws_region}"
    }
  }

}

resource "aws_cloudwatch_log_group" "exampleFunction" {
  name              = "/aws/lambda/${aws_lambda_function.exampleFunction_function.function_name}"
  retention_in_days = var.default_log_retention_days
}

resource "aws_iam_role" "exampleFunction_role" {
  name = "${var.exampleFunction_function_name}_role"

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
    name = "exampleFunction_inline_policy"

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

resource "aws_iam_role_policy_attachment" "exampleFunction_policy_attachment_basic" {
  role       = aws_iam_role.exampleFunction_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Variables
#####################################
variable "exampleFunction_function_name" { type = string } # default="vlt-exampleFunction"

variable "exampleFunction_function_handler" { type = string } # default="exampleFunction.handler"

variable "exampleFunction_function_timeout_seconds" { type = string } # default=60

variable "exampleFunction_function_memory_size_mb" { type = string } # default=128