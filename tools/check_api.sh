#!/bin/bash
# check_api.sh — Test JSearch API key is valid
# Usage: ./tools/check_api.sh

# Read key from environment or prompt
API_KEY="${JSEARCH_API_KEY:-}"

if [ -z "$API_KEY" ]; then
  echo "Enter your JSearch (OpenWebNinja) API key:"
  read -r API_KEY
fi

echo "Testing JSearch API..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  "https://api.openwebninja.com/jsearch/search?query=software+engineer&page=1&num_pages=1" \
  -H "x-api-key: $API_KEY")

if [ "$RESPONSE" == "200" ]; then
  echo "✅ API key valid — JSearch responding"
else
  echo "❌ API returned HTTP $RESPONSE — key may be invalid or expired"
fi
