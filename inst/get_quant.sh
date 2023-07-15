#!/bin/bash

# usage: get_quant.sh lookup.txt output_datadir

lookup=$1

# Define the local base path where directories will be created
local_base_path=$2

# Define the base S3 path
s3_base_path="s3://llfs/default_processing/"


# Read each line in the file
while IFS= read -r dir_name
do
  # Create directory
  mkdir -p "$local_base_path/$dir_name"

  # Formulate full S3 path
  full_s3_path="$s3_base_path$dir_name/star_rsem/"

  # Use s3cmd to get data from S3
  s3cmd get --recursive --exclude="*" --include="*.results" $full_s3_path $local_base_path/$dir_name/
done < "${lookup}"

