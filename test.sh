#!/bin/bash
source scripts/build-functions.sh
add_variables_to_tfvars "infrastructure/template/lambda-base.template" "test.tfvars"