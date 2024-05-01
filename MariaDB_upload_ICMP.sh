#!/bin/bash

TABLE_NAME=$1
MONTH_NAME=$2
# Directory containing your files
DIRECTORY_BASE='/home/mes/bachelors/'
DIRECTORY=${DIRECTORY_BASE}${MONTH_NAME}'_processed_icmp'

# MariaDB database credentials
DB_USER='root'
DB_PASS='root'
DB_NAME='TCP_UDP_DATA'


# Loop through each file in the directory
for file in "$DIRECTORY"/*; do
  echo "Uploading file $file"
  mariadb -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "    LOAD DATA LOCAL INFILE '$file'
    INTO TABLE $TABLE_NAME
    FIELDS TERMINATED BY '\t' ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (epoch_time, protocol, icmp_type, icmp_code, ip_src, ip_dst, src_country);"
done

echo "All files have been uploaded."

