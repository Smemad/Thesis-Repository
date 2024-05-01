#!/bin/bash

# Validate input directory
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "The provided path is not a directory."
    exit 2
fi

input_directory="$1"
input_dir_basename=$(basename "$input_directory")
output_directory="${input_dir_basename}_processed_icmp"

# Create output directory if it does not exist
mkdir -p "$output_directory"

# Initialize counter
file_counter=1

# Find all files in the directory, not just .pcap to process every file
files=("$input_directory"/*)

# Process files in parallel, two at a time
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        # Construct the output file name
        output_file="${output_directory}/${input_dir_basename}_${file_counter}.csv"
        ((file_counter++))

        # Run the tshark command in the background on each file
        tshark -r "$file" -Y icmp -T fields -e frame.time_epoch \
	-e _ws.col.Protocol -e icmp.type -e icmp.code -e ip.src \
	-e ip.dst -e ip.geoip.src_country -E header=y -E separator=$'\t' \
	-E quote=d -E occurrence=f > "$output_file" &

        # Every two jobs, wait for all background jobs to finish before continuing
        if (( file_counter % 2 == 0 )); then
            wait
        fi
    fi
done

# Wait for the last set of jobs if they haven't finished
wait

echo "Processing complete. Output files are in $output_directory"
