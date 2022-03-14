#!/usr/bin/bash -v
set -e
source buildscripts/build-vars.sh

mkdir -p $rootDir/build

cd $lambda_root
npm install
npm run esbuild

# Zip up the lambda code
cd $rootDir
buildscripts/zip-lambdas.sh $environment

# Terraform
cd $rootDir/$tf_wd

# specific file needed on init to load the providers for Jenkins
terraform init -backend=false
terraform fmt
terraform validate

if test -f "$tf_vars_file"; then
    terraform init -backend-config=$tf_backend_file -var-file=$tf_vars_file
    terraform plan -out=$tf_plan -var-file=$tf_vars_file
fi