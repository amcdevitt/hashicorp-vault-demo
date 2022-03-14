lambda_template_replace_variables_and_write_file() {
    local fileToStream=$1
    local fileToWrite=$2
    local zip_name=$3
    local lambda_name=$4
    local lambda_entry_point=$5
    local project_prefix=$6

    echo "Arguments: $fileToStream, $fileToWrite, $zip_name, $lambda_name, $lambda_entry_point, $project_prefix"

    # Escape the slashes in the entry point
    #lambda_entry_point=`echo $lambda_entry_point | sed 's/\//+++/g'`

    echo "Replacing variables in $fileToStream"

    cat $fileToStream \
    | sed s/{{zip_name}}/$zip_name/g \
    | sed s/{{lambda_name}}/$lambda_name/g \
    | sed s!{{lambda_entry_point}}!$lambda_entry_point!g \
    | sed s/{{project_prefix}}/$project_prefix/g \
    > $fileToWrite
}

add_variables_to_tfvars() {
    local file_to_read_variables_from=$1
    local file_to_write_variables_to=$2
    local base_output_file_name=`basename $1`

    echo "Arguments to $0: $file_to_read_variables_from, $file_to_write_variables_to"

    if [ -f "$file_to_read_variables_from" ]; then
        echo "Reading variables from: $file_to_read_variables_from"
        printf "\n\n" >> $file_to_write_variables_to
        printf "# Variables from file: ${base_output_file_name}\n" >> $file_to_write_variables_to
        printf "#####################################\n" >> $file_to_write_variables_to
        cat $file_to_read_variables_from \
        | gawk '{ match($0, /variable "(.*)".*#.*default=(.*)/, arr); if(arr[1] != "") print arr[1]" = "arr[2] }' \
        >> $file_to_write_variables_to
    fi
}

generate_manifest_file() {
    local folder_to_read=$1
    local character_count=`echo $folder_to_read | wc -c`
    local manifest_file_name="manifest.txt"

    echo "Arguments to $0: $folder_to_read, $character_count"

    rm $folder_to_read/$manifest_file_name 2> /dev/null

    find $folder_to_read -name "*" -type f \
    | cut -c $character_count- \
    | sed "s/^\///" \
    | sed "/$manifest_file_name/d" \
    >> $folder_to_read/$manifest_file_name
}
