resource "aws_api_gateway_rest_api" "request-router_gateway" {
  name        = "request-router-api"
  description = "The request-router api"
  #body        = data.template_file.request-router_gateway.rendered
  body = templatefile("../${var.lambda_root_dir}/${var.request_router_swagger_file}",
    {
      aws_region    = var.aws_region
      router_lambda = aws_lambda_function.request-router_function.arn
  })
}

resource "aws_api_gateway_deployment" "request-router_gateway" {
  rest_api_id = aws_api_gateway_rest_api.request-router_gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.request-router_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "request-router_gateway_v1" {
  deployment_id = aws_api_gateway_deployment.request-router_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.request-router_gateway.id
  stage_name    = "v1"
}

resource "aws_lambda_permission" "request-router_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.request-router_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.request-router_gateway.execution_arn}/*/*"
}
