output "request-router-endpoint" {
  description = "The endpoint to call for request router lambda"
  value       = aws_api_gateway_stage.request-router_gateway_v1.invoke_url
}
