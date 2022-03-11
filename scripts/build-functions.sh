lambda_template_replace_variables_and_write_file() {
    local fileToStream=$1
    local fileToWrite=$2
    local zip_name=$3
    local lambda_name=$4

    echo "Arguments: $fileToStream, $fileToWrite, $zip_name, $lambda_name"

    cat $fileToStream | sed s/{{zip_name}}/$zip_name/g | sed s/{{lambda_name}}/$lambda_name/g > $fileToWrite    
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