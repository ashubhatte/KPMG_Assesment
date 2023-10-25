#!/bin/bash

# Query Azure IMDS for instance metadata
metadata_url="http://169.254.169.254/metadata/instance?api-version=2021-02-01"

# Use curl to make a GET request to the IMDS endpoint
metadata_json=$(curl -s $metadata_url)

# Check if the request was successful
if [ $? -eq 0 ]; then
  echo "Instance metadata retrieved successfully:"
  echo $metadata_json | jq '.'  # Use 'jq' to pretty-print the JSON
else
  echo "Failed to retrieve instance metadata."
fi
