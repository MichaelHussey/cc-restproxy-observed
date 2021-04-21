#!/bin/bash

echo -e "\n====== Create cloud api-key and set environment variables for the ccloud-exporter"
echo "ccloud api-key create --resource cloud --description \"confluent-cloud-metrics-api\" -o json"
OUTPUT=$(ccloud api-key create --resource cloud --description "confluent-cloud-metrics-api" -o json)
rm .env 2>/dev/null
echo "$OUTPUT" | jq .
export METRICS_API_KEY=$(echo "$OUTPUT" | jq -r ".key")
export METRICS_API_SECRET=$(echo "$OUTPUT" | jq -r ".secret")
echo -e "\n====== Provide a comma-separated list of clusters to monitor"
echo "export CLOUD_CLUSTER="