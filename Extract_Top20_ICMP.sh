#!/bin/bash

# Database credentials
DB_USER="root"
DB_PASS="root"
DB_NAME="TCP_UDP_DATA"
HOST="localhost"

# Table name
TABLE_NAME=$1

# Output directory
OUTPUT_DIR="/home/mes/bachelors/top20_icmp/${TABLE_NAME}"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Function to export top 21 of a column to a file
export_top20 () {
    COLUMN_NAME=$1
    QUERY="SELECT $COLUMN_NAME, COUNT(*) AS count FROM $TABLE_NAME GROUP BY $COLUMN_NAME ORDER BY count DESC LIMIT 20;"
    OUTFILE="${OUTPUT_DIR}top20_${COLUMN_NAME}.csv"

    echo "Exporting top 20 for $COLUMN_NAME..."
    mariadb -u"$DB_USER" -p"$DB_PASS" -h "$HOST" -e "$QUERY" "$DB_NAME" > "$OUTFILE"
}

# Columns to process
COLUMNS=("ip_src" "ip_dst" "src_country" "icmp_type" "icmp_code" "protocol")

# Loop through columns and export data
for COLUMN in "${COLUMNS[@]}"; do
    export_top20 "$COLUMN"
done

echo "Data export completed."
