# AWS
#####################################
aws_region                 = "us-east-1"
aws_profile                = "default"
upload_s3_bucket           = "sprocket-dev-1-lambda"
log_level                  = "trace"
default_log_retention_days = 7
environment                = "dev"
global_tag_purpose         = "vault-test"

# Account Creation lambda
#####################################
vault_test_function_name            = "test-function"
vault_test_function_handler         = "test-function.handler"
vault_test_function_timeout_seconds = 30
vault_test_function_memory_size_mb  = 256

# Default VPC
#####################################
vault_demo_vpc_cidr = "10.0.0.0/16"
vault_demo_vpc_name = "vault-demo-vpc"

# Default Secutity Group
#####################################
vault_demo_security_group_name = "vault-demo-security-group"

# Default Subnet
#####################################
vault_demo_subnet_cidr = "10.0.0.0/16"
vault_demo_subnet_name = "vault-demo-subnet"


# Variables from file: lambda-exampleFunction.tf
#####################################
exampleFunction_function_name            = "vlt-exampleFunction"
exampleFunction_function_handler         = "exampleFunction.handler"
exampleFunction_function_timeout_seconds = 60
exampleFunction_function_memory_size_mb  = 128


# Variables from file: lambda-anotherFunction.tf
#####################################
anotherFunction_function_name            = "vlt-anotherFunction"
anotherFunction_function_handler         = "anotherFunction.handler"
anotherFunction_function_timeout_seconds = 60
anotherFunction_function_memory_size_mb  = 128
