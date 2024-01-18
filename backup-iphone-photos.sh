#!/usr/bin/bash
set -e

# File to store the list of processed subfolders
processed_subfolders_file="$PWD/processed_subfolders.txt"

# Source directory where subfolders are located
source_root_dir="/home/hank/iPhone/DCIM"
destination_dir="/run/media/hank/SANDISK/hank/iphone-photo"

# Check if the source directory exists
if [ ! -d "$source_root_dir" ]; then
    echo "Error: Source directory '$source_root_dir' does not exist."
    exit 1
fi

# Check if the destination directory exists
if [ ! -d "$destination_dir" ]; then
    echo "Error: Destination directory '$destination_dir' does not exist."
    exit 1
fi

# Read the list of processed subfolders from the file
if [ -f "$processed_subfolders_file" ]; then
    processed_subfolders=$(cat "$processed_subfolders_file")
else
    processed_subfolders=""
fi

# Iterate through each subfolder in the source directory
for source_subfolder in "$source_root_dir"/*/; do
    # Extract the subfolder name from the path
    subfolder_name=$(basename "$source_subfolder")

    # Check if the current subfolder has been processed before
    if [[ "$processed_subfolders" =~ $subfolder_name && "$subfolder_name" != "${processed_subfolders##* }" ]]; then
        echo "Skipping already processed subfolder: $subfolder_name"
        continue
    fi

    # Run the synchronization process
    for file in "$source_subfolder"*; do
        if [ -f "$file" ]; then
            last_modified=$(stat -c %Y "$file")
            year_month=$(date -d "@$last_modified" +%Y-%m)
            mkdir -p "$destination_dir/$year_month"
            rsync -a --ignore-existing "$file" "$destination_dir/$year_month/"
            echo "Copied $file to $destination_dir/$year_month/"
        fi
    done

    # Update the list of processed subfolders, excluding the last one
    if [ -n "$processed_subfolders" ]; then
        processed_subfolders="${processed_subfolders% *} "
    fi
    processed_subfolders="$processed_subfolders$subfolder_name"
    echo "$processed_subfolders" > "$processed_subfolders_file"
done

echo "Backup process completed."

