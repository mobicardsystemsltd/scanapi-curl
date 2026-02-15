#!/bin/bash

# Configuration
MOBICARD_VERSION="2.0"
MOBICARD_MODE="LIVE"
MOBICARD_MERCHANT_ID=""
MOBICARD_API_KEY=""
MOBICARD_SECRET_KEY=""
MOBICARD_TOKEN_ID=$(shuf -i 1000000-1000000000 -n 1)
MOBICARD_TXN_REFERENCE=$(shuf -i 1000000-1000000000 -n 1)
MOBICARD_SERVICE_ID="20000"
MOBICARD_SERVICE_TYPE="1"
MOBICARD_EXTRA_DATA="your_custom_data_here_will_be_returned_as_is"

# Create JWT Header
JWT_HEADER=$(echo -n '{"typ":"JWT","alg":"HS256"}' | base64 | tr '+/' '-_' | tr -d '=')

# Create JWT Payload
PAYLOAD_JSON=$(cat << EOF
{
  "mobicard_version": "$MOBICARD_VERSION",
  "mobicard_mode": "$MOBICARD_MODE",
  "mobicard_merchant_id": "$MOBICARD_MERCHANT_ID",
  "mobicard_api_key": "$MOBICARD_API_KEY",
  "mobicard_service_id": "$MOBICARD_SERVICE_ID",
  "mobicard_service_type": "$MOBICARD_SERVICE_TYPE",
  "mobicard_token_id": "$MOBICARD_TOKEN_ID",
  "mobicard_txn_reference": "$MOBICARD_TXN_REFERENCE",
  "mobicard_extra_data": "$MOBICARD_EXTRA_DATA"
}
EOF
)

JWT_PAYLOAD=$(echo -n "$PAYLOAD_JSON" | base64 | tr '+/' '-_' | tr -d '=')

# Generate Signature
HEADER_PAYLOAD="$JWT_HEADER.$JWT_PAYLOAD"
JWT_SIGNATURE=$(echo -n "$HEADER_PAYLOAD" | openssl dgst -sha256 -hmac "$MOBICARD_SECRET_KEY" -binary | base64 | tr '+/' '-_' | tr -d '=')

# Create Final JWT
MOBICARD_AUTH_JWT="$JWT_HEADER.$JWT_PAYLOAD.$JWT_SIGNATURE"

# Request Access Token
API_URL="https://mobicardsystems.com/api/v1/card_scan"

RESPONSE=$(curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "{\"mobicard_auth_jwt\":\"$MOBICARD_AUTH_JWT\"}" \
  --silent)

# Parse and display response
echo "$RESPONSE" | python -m json.tool
