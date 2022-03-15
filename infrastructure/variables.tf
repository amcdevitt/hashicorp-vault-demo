# AWS
#####################################
variable "aws_region" {
  description = "AWS region for all resources."

  type = string
}

variable "aws_profile" {
  description = "AWS profile to use for all resources."

  type = string
}

variable "log_level" {
  description = "Logging level for Lambda functions"

  type = string
}

variable "upload_s3_bucket" {
  description = "S3 bucket to store the backend files."

  type = string
}

variable "default_log_retention_days" {
  description = "Default number of days to retain logs."
  type        = number
}

variable "environment" {
  description = "prod, test, etc..."
  type        = string
}

variable "global_tag_purpose" {
  description = "Tag for all resources"
  type        = string
}

# Build
#####################################
variable "lambda_root_dir" {
  type = string
}

# Account Creation lambda
#####################################
variable "vault_test_function_name" {
  type = string
}

variable "vault_test_function_handler" {
  type = string
}

variable "vault_test_function_timeout_seconds" {
  type = number
}

variable "vault_test_function_memory_size_mb" {
  type = number
}

# Default VPC
#####################################
variable "vault_demo_vpc_cidr" {
  description = "CIDR block for the default VPC"
  type        = string
}

variable "vault_demo_vpc_name" {
  description = "Name of the default VPC"
  type        = string
}

# Default Security Group
#####################################
variable "vault_demo_security_group_name" {
  description = "Name of the default security group"
  type        = string
}

# Default Subnet
#####################################
variable "vault_demo_subnet_cidr" {
  description = "CIDR block for the default subnet"
  type        = string
}

variable "vault_demo_subnet_name" {
  description = "Name of the default subnet"
  type        = string
}

# Request Router Lambda
#####################################
variable "request_router_swagger_file" {
  type = string
}
