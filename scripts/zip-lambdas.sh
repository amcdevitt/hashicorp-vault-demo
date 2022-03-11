#!/usr/bin/bash
set -e
source scripts/build-vars.sh $1
source scripts/build-functions.sh

lambda_upload_tf_file=lambda-upload.tf

rm -rf $rootDir/build/*
cd $rootDir/$lambda_root/build

echo "" > $rootDir/build/$lambda_upload_tf_file

for FILE in *; do 

    if [[ $FILE == *"js" ]]; then
        
        file_name="${FILE%.*}"
        echo "zip base name: $file_name"

        zip "$file_name.zip" "$file_name.js" "$file_name.js.map"

        mv "$file_name.zip" "$rootDir/build/"

        # Add the zip file to the terraform file
        cat $lambda_upload_tf_template | sed s/{{zip_name}}/$file_name/g >> $rootDir/build/$lambda_upload_tf_file
        printf "\n\n" >> $rootDir/build/$lambda_upload_tf_file

        # If the lambda terraform file does not exist, write it out
        lambda_generated_file="$rootDir/build/lambda-${file_name}.tf"
        lambda_template_replace_variables_and_write_file "$lambda_tf_template" "$lambda_generated_file" "$file_name" "$file_name"

        if [ ! -f "$rootDir/$tf_wd/${file_name}_lambda.tf" ]; then
            echo "Writing out lambda terraform file: $rootDir/$tf_wd/${file_name}_lambda.tf"
            output_generated_file=$rootDir/$tf_wd/${file_name}_lambda.tf
            mv $lambda_generated_file $output_generated_file

            # Add the variables to the tfvars file
            add_variables_to_tfvars "$output_generated_file" "$rootDir/$tf_wd/$tf_vars_file"
        fi

        continue
    fi

done

cd $rootDir/build
terraform fmt
mv $lambda_upload_tf_file $rootDir/$tf_wd/$lambda_upload_tf_file
