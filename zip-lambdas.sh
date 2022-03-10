#!/usr/bin/bash
set -e
source build-vars.sh

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
        cat $rootDir/$tf_wd/template/$lambda_tf_template | sed s/{{zip_name}}/$file_name/g >> $rootDir/build/$lambda_upload_tf_file
        printf "\n\n" >> $rootDir/build/$lambda_upload_tf_file
        continue
    fi

done

cd $rootDir/build
terraform fmt
mv $lambda_upload_tf_file $rootDir/$tf_wd/$lambda_upload_tf_file
