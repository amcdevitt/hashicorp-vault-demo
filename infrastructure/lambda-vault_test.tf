
resource "aws_lambda_function" "vault_test_lambda" {
  function_name = var.vault_test_function_name

  s3_bucket = aws_s3_bucket.lambda_archive_and_upload.id
  s3_key    = aws_s3_object.vault_test_lambda.key

  runtime = "nodejs14.x"
  handler = var.vault_test_function_handler

  source_code_hash = filebase64sha256("../build/vault_test.zip")

  role = aws_iam_role.vault_test_lambda.arn

  timeout     = var.vault_test_function_timeout_seconds
  memory_size = var.vault_test_function_memory_size_mb

  environment {
    variables = {
      "SPROCKET_VAULT_API_VERSION" = ""
      "SPROCKET_VAULT_ENDPOINT"    = ""
      "SPROCKET_TOKEN"             = ""
      "SPROCKET_VAULT_HOST"        = ""
      "SPROCKET_VAULT_NAMESPACE"   = ""
    }
  }

  lifecycle {
    ignore_changes = [
      environment.0.variables["SPROCKET_VAULT_API_VERSION"],
      environment.0.variables["SPROCKET_VAULT_ENDPOINT"],
      environment.0.variables["SPROCKET_VAULT_TOKEN"],
      environment.0.variables["SPROCKET_VAULT_HOST"],
      environment.0.variables["SPROCKET_VAULT_NAMESPACE"]
    ]
  }

  vpc_config {
    subnet_ids         = [aws_subnet.vault_demo_default_subnet_private.id]
    security_group_ids = [aws_security_group.vault_demo_default_security_group.id]
  }

  # Adding layer for the hashicorp vault
  #layers = [
  #  "arn:aws:lambda:${var.aws_region}:634166935893:layer:vault-lambda-extension:11",
  #]

}

resource "aws_cloudwatch_log_group" "vault_test_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.vault_test_lambda.function_name}"
  retention_in_days = var.default_log_retention_days
}

data "aws_iam_policy_document" "vault_test_lambda_policy" {
  statement {
    sid     = "LambdaRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vault_test_lambda" {
  name = var.vault_test_function_name

  assume_role_policy = data.aws_iam_policy_document.vault_test_lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "vault_test_lambda_basic" {
  role       = aws_iam_role.vault_test_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vault_test_lambda_vpc_access_execution" {
  role       = aws_iam_role.vault_test_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
