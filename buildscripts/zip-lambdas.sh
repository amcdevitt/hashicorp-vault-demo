#!/usr/bin/bash
set -e
source buildscripts/build-vars.sh $1
source buildscripts/build-functions.sh

lambda_upload_tf_file=lambda-upload.tf

rm -rf $rootDir/build/*

lambda_build_dir=$rootDir/$lambda_root/build
cd $lambda_build_dir

echo "" > $rootDir/build/$lambda_upload_tf_file

project_prefix=$(cat "../build-config.json" | jq -rc '.project.prefix')

for config in $(cat "../build-config.json" | jq -rc '.lambdas[]'); do

    lambda_name=`echo ${config} | jq -r '.name'`
    lambda_entry_point=`echo ${config} | jq -r '.esbuildEntrypoint'`

    echo "Building lambda zip: $lambda_name ..."

    echo "Current directory: $(pwd)"
    cd "$lambda_name"

    find . -name "*" -type f | xargs touch -t 202203070000
    echo "zip base name: $lambda_name"

    zip -rXD "$lambda_name.zip" .
    touch -t 202203070000 "$lambda_name.zip"

    mv "$lambda_name.zip" "$rootDir/build/"

    # Add the zip file to the terraform file
    cat $lambda_upload_tf_template \
    | sed s/{{lambda_name}}/$lambda_name/g \
    | sed s!{{lambda_entry_point}}!$lambda_entry_point!g \
    >> $rootDir/build/$lambda_upload_tf_file

    printf "\n\n" >> $rootDir/build/$lambda_upload_tf_file

    # If the lambda terraform file does not exist, write it out
    lambda_generated_file="$rootDir/build/lambda-${lambda_name}.tf"
    lambda_template_replace_variables_and_write_file "$lambda_tf_template" "$lambda_generated_file" "$lambda_name" "$lambda_name" "$lambda_entry_point" "$project_prefix"

    output_generated_file="$rootDir/$tf_wd/lambda-${lambda_name}.tf"
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
