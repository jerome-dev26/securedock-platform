#!/bin/bash

set -euo pipefail

# Usage: ./aws_secrets_manager.sh <SECRET_NAME> <REGION>
# Example: ./aws_secrets_manager.sh my-app-secrets us-east-1

SECRET_NAME=$1
REGION=$2

if [ -z "$SECRET_NAME" ] || [ -z "$REGION" ]; then
  echo "Usage: $0 <SECRET_NAME> <REGION>"
  exit 1
fi

echo "Fetching secret: ${SECRET_NAME} from region: ${REGION}"

# Fetch the secret value
SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text --region "$REGION")

# Output the secret value (e.g., for use in environment variables)
echo "${SECRET_VALUE}"
