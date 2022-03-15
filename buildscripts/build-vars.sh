#!/usr/bin/bash

environment=$1

if( [ -z "$environment" ] ); then
    environment="local"
fi

echo "Running build for environment: $environment"

rootDir=$(pwd)
echo "Root directory: $rootDir"
# Build
build_script_dir=$rootDir/buildscripts
infra_template_dir=$build_script_dir/infratemplates

cd $rootDir/lambda
project_name=$(cat "build-config.json" | jq -rc '.project.name')
project_name=$(echo $project_name | sed 's! !!g')
cd $rootDir

# Terraform
tf_wd=infrastructure
tf_plan="$project_name-plan.out"
tf_backend_file="$environment.backend.tfvars"
tf_vars_file="$environment.variables.tfvars"
tf_logging_level=INFO

# Lambda
lambda_root=lambda
lambda_upload_tf_template=$infra_template_dir/lambda-zip-s3-upload.template
lambda_tf_template=$infra_template_dir/lambda-base.template
build_config_file=$rootDir/$lambda_root/build-config.json

BUILD_VARS_FILE=build-vars-override.sh
if test -f "$BUILD_VARS_FILE"; then
    source $BUILD_VARS_FILE
fi