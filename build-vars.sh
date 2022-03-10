#!/usr/bin/bash

environment=$1

if( [ -z "$environment" ] ); then
    environment="local"
fi

echo "Running build for environment: $environment"

rootDir=$(pwd)

# Terraform
tf_wd=infrastructure
tf_plan=account-creation-plan.out
tf_backend_file=$environment.backend.tfvars
tf_vars_file=$environment.variables.tfvars
tf_logging_level=DEBUG

# Lambda
lambda_root=lambda
lambda_tf_template=lambda-zip-s3-upload.template

BUILD_VARS_FILE=build-vars-override.sh
if test -f "$BUILD_VARS_FILE"; then
    source $BUILD_VARS_FILE
fi