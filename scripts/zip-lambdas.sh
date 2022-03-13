#!/usr/bin/bash
set -e
source scripts/build-vars.sh $1
source scripts/build-functions.sh

lambda_upload_tf_file=lambda-upload.tf

rm -rf $rootDir/build/*

lambda_build_dir=$rootDir/$lambda_root/build
cd $lambda_build_dir

echo "" > $rootDir/build/$lambda_upload_tf_file

for config in $(cat "../build-config.json" | jq -rc '.lambdas[]'); do

    lambda_name=`echo ${config} | jq -r '.name'`
    echo "Building lambda zip: $lambda_name ..."

    echo "Current directory: $(pwd)"
    cd "$lambda_name"

    echo "zip base name: $lambda_name"

    zip -r "$lambda_name.zip" .

    mv "$lambda_name.zip" "$rootDir/build/"

    # Add the zip file to the terraform file
    cat $lambda_upload_tf_template | sed s/{{zip_name}}/$lambda_name/g >> $rootDir/build/$lambda_upload_tf_file
    printf "\n\n" >> $rootDir/build/$lambda_upload_tf_file

    # If the lambda terraform file does not exist, write it out
    lambda_generated_file="$rootDir/build/lambda-${lambda_name}.tf"
    lambda_template_replace_variables_and_write_file "$lambda_tf_template" "$lambda_generated_file" "$lambda_name" "$lambda_name"

    output_generated_file=$rootDir/$tf_wd/${lambda_name}_lambda.tf
    if [ ! -f "$output_generated_file" ]; then
        echo "Writing out lambda terraform file: $output_generated_file"
        mv $lambda_generated_file $output_generated_file

        # Add the variables to the tfvars file
        add_variables_to_tfvars "$output_generated_file" "$rootDir/$tf_wd/$tf_vars_file"
    fi

    cd ..
    continue

done

cd $rootDir/build
terraform fmt
mv $lambda_upload_tf_file $rootDir/$tf_wd/$lambda_upload_tf_file
