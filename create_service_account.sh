#!/bin/bash

SERVICE_NAME="${SERVICE_NAME:-rp_observed}"

# Set up a new service account if needed
[[ -z $SERVICE_ACCOUNT_ID ]] && {
  CCLOUD_EMAIL=$(ccloud prompt -f '%u')
  OUTPUT=$(ccloud service-account create $SERVICE_NAME --description "SA for $EXAMPLE run by $CCLOUD_EMAIL"  -o json)
  SERVICE_ACCOUNT_ID=$(echo "$OUTPUT" | jq -r ".id")

  echo "Created Service Account, id: $SERVICE_ACCOUNT_ID"
  echo "export SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID"
}

# Create up a new API key if needed
[[ -z $API_SECRET_SA ]] && {
  RESOURCE=$CLUSTER_ID
  OUTPUT=$(ccloud api-key create --service-account $SERVICE_ACCOUNT_ID --resource $RESOURCE -o json)
  API_KEY_SA=$(echo "$OUTPUT" | jq -r ".key")
  API_SECRET_SA=$(echo "$OUTPUT" | jq -r ".secret")

  echo "Created new API Key for Service Account ${API_KEY_SA}:${API_SECRET_SA}"
  echo "export API_KEY_SA=$API_KEY_SA"
  echo "export API_SECRET_SA=$API_SECRET_SA"
}

  # Setting default QUIET=false to surface potential errors
  QUIET="${QUIET:-false}"
  [[ $QUIET == "true" ]] &&
    REDIRECT_TO="/dev/null" ||
    REDIRECT_TO="/dev/stdout"

  # Set the ACLs needed by RP:
  # TODO - figure the minimal set of configs for produce and consume, these are too permissive
  ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation CREATE --topic '*' &>"$REDIRECT_TO"
  ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation DELETE --topic '*' &>"$REDIRECT_TO"
  ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation WRITE --topic '*' &>"$REDIRECT_TO"
  ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation READ --topic '*' &>"$REDIRECT_TO"
  ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation DESCRIBE --topic '*' &>"$REDIRECT_TO"
  ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation DESCRIBE_CONFIGS --topic '*' &>"$REDIRECT_TO"


echo "export SASL_JAAS_CONFIG=\"org.apache.kafka.common.security.plain.PlainLoginModule required username='${API_KEY_SA}' password='${API_SECRET_SA}';\""    

endpoint=$(ccloud kafka cluster describe $CLUSTER_ID -o json | jq -r ".endpoint" | cut -c 12-)
echo "export BOOTSTRAP_SERVERS=$endpoint"