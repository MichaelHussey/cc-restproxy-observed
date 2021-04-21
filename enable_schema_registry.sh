#!/bin/bash

  SCHEMA_REGISTRY_CLOUD="${SCHEMA_REGISTRY_CLOUD:-aws}"
  SCHEMA_REGISTRY_GEO="${SCHEMA_REGISTRY_GEO:-eu}"

  OUTPUT=$(ccloud schema-registry cluster enable --cloud $SCHEMA_REGISTRY_CLOUD --geo $SCHEMA_REGISTRY_GEO -o json)
  SCHEMA_REGISTRY=$(echo "$OUTPUT" | jq -r ".id")

  echo $SCHEMA_REGISTRY

SCHEMA_REGISTRY_ENDPOINT=$(ccloud schema-registry cluster describe -o json | jq -r ".endpoint_url")  
echo "export SCHEMA_REGISTRY_URL=$SCHEMA_REGISTRY_ENDPOINT"
echo "export BASIC_AUTH_CREDENTIALS_SOURCE=USER_INFO"

[[ -z $SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO ]] && {

  # Create an API key if needed
  OUTPUT=$(ccloud api-key create --service-account $SERVICE_ACCOUNT_ID --resource $SCHEMA_REGISTRY -o json)
  SR_API_KEY_SA=$(echo "$OUTPUT" | jq -r ".key")
  SR_API_SECRET_SA=$(echo "$OUTPUT" | jq -r ".secret")

  echo "Created new API Key on Schema Registry for Service Account ${SR_API_KEY_SA}:${SR_API_SECRET_SA}"
  echo "export SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO=$SR_API_KEY_SA:$SR_API_SECRET_SA"
}

