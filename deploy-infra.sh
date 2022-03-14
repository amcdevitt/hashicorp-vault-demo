#!/usr/bin/bash -v
set -e
source buildscripts/build-vars.sh

export TF_LOG=$tf_logging_level

cd $tf_wd
terraform apply -auto-approve $tf_plan