#!/bin/bash
source scripts/build-functions.sh
test=`cat "./lambda/build-config.json" | jq -rc '.lambdas[]'`
echo "Test: $test"

for config in $(cat "./lambda/build-config.json" | jq -rc '.lambdas[]'); do

    lambda_name=`echo ${config} | jq -r '.name'`
    echo "Building lambda: $lambda_name ..."
done