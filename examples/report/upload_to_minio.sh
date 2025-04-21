#!/bin/bash

# Usage: ./upload_to_minio.sh <local_directory> <minio_alias> <bucket_name> [<bucket_prefix>]

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <local_directory> <minio_alias> <bucket_name> [<bucket_prefix>]"
    exit 1
fi

LOCAL_DIR="$1"
MINIO_ALIAS="$2"
BUCKET_NAME="$3"
BUCKET_PREFIX="${4:-}"  # Optional path within the bucket

# Ensure trailing slash on local dir
LOCAL_DIR="${LOCAL_DIR%/}/"

# Check if directory exists
if [ ! -d "$LOCAL_DIR" ]; then
    echo "Error: Directory $LOCAL_DIR does not exist."
    exit 1
fi

# Check if bucket exists
if ! mc ls "$MINIO_ALIAS/$BUCKET_NAME" &> /dev/null; then
    echo "Bucket '$BUCKET_NAME' does not exist on '$MINIO_ALIAS'. Creating it..."
    mc mb "$MINIO_ALIAS/$BUCKET_NAME"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create bucket '$BUCKET_NAME'."
        exit 1
    fi
fi

# Perform upload
echo "Uploading '$LOCAL_DIR' to '$MINIO_ALIAS/$BUCKET_NAME/$BUCKET_PREFIX'..."
mc mirror --overwrite "$LOCAL_DIR" "$MINIO_ALIAS/$BUCKET_NAME/$BUCKET_PREFIX"

if [ $? -eq 0 ]; then
    echo "✅ Upload completed successfully!"
else
    echo "❌ Upload failed."
    exit 1
fi