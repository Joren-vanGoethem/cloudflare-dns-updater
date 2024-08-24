#!/bin/bash

# Cloudflare credentials
CF_API_KEY=${CF_API_KEY}
CF_EMAIL=${CF_EMAIL}
CF_ZONE_ID=${CF_ZONE_ID}
CF_RECORD_ID=${CF_RECORD_ID}
CF_RECORD_NAME=${CF_RECORD_NAME}
CF_RECORD_TYPE=${CF_RECORD_TYPE}
CF_TTL=${CF_TTL}
CF_PROXIED=${CF_PROXIED}

# Get the current IP address
CURRENT_UP=${curl -s http://ipinfo.io/ip}

# Update DNS record on Cloudflare

RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records/${CF_RECORD_ID}" \
    -H "Content-Type: application/json" \
    -H "X-Auth-Email: ${CF_EMAIL}" \
    -H "X-Auth-Key: ${CF_API_KEY}" \
    --data "{\"type\":\"${CF_RECORD_TYPE}\",\"name\":\"${CF_RECORD_NAME}\",\"content\":\"${CURRENT_IP}\",\"ttl\":${CF_TTL},\"proxied\":${CF_PROXIED}}")

# Check if the update was successful
if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "DNS record updated successfully."
else
    echo "Failed to update DNS record:"
    echo "$RESPONSE"
fi
