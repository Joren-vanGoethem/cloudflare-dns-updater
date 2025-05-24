#!/bin/bash
# Cloudflare credentials
CF_EMAIL="jorenvangoethem@hotmail.com"
CF_API_KEY="994c98338fb6c401b5e32331d538f01679612"
CF_ZONE_ID="d7520ffddcee4411b95821306e0c9c9f"
CF_RECORD_ID="64241674f943208954eaaf3de856cd66"
CF_RECORD_NAME="prestana.eu"
CF_RECORD_TYPE="A"
CF_TTL=120
CF_PROXIED=false

get_my_ipv4() {
    CURRENT_IP=$(curl -s http://ipv4.icanhazip.com)

    if [ -z "${CURRENT_IP}" ]; then
        CURRENT_IP=$(curl -s http://ipinfo.io/ip)
    fi

    echo "${CURRENT_IP}"
}

resolve_domain_ipv4() {
    resolved_ip=$(nslookup "${CF_RECORD_NAME}" | awk '/^Address: / { print $2 }' | head -n1)
    echo "${resolved_ip}"
}

resolve_domain_ipv6() {
    resolved_ip=$(nslookup "${CF_RECORD_NAME}" | awk '/^Address: / { print $2 }' | tail -n1)
    echo "${resolved_ip}"
}

resolve_cloudflare_record() {
    
}

domain_ipv4=$(resolve_domain_ipv4)
current_ipv4=$(get_my_ipv4)
echo "Resolved IP for ${CF_RECORD_NAME}: ${domain_ipv4}"
echo "Current ip: ${current_ipv4}"

# Get IP from Cloudflare DNS record
CLOUDFLARE_IP=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records" \
    -H "X-Auth-Email: ${CF_EMAIL}" \
    -H "X-Auth-Key: ${CF_API_KEY}" | jq -r '.result[0].content')

# TODO: create a method that also checks for the correct record type

echo "${CLOUDFLARE_IP}"
#echo "${CURRENT_IP}" == "${CLOUDFLARE_IP}"
#
## Compare IPs
#if [ CURRENT_IP == CLOUDFLARE_IP ]; then
#    echo "IP address has not changed. No update needed."
#    exit 0
#fi

# Update DNS record
#RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records/${CF_RECORD_ID}" \
#    -H "Content-Type: application/json" \
#    -H "X-Auth-Email: ${CF_EMAIL}" \
#    -H "X-Auth-Key: ${CF_API_KEY}" \
#    --data "{\"type\":\"${CF_RECORD_TYPE}\",\"name\":\"${CF_RECORD_NAME}\",\"content\":\"${CURRENT_IP}\",\"ttl\":${CF_TTL},\"proxied\":${CF_PROXIED}}")
#
## Check if the update was successful
#if echo "$RESPONSE" | grep -q '"success":true'; then
#    echo "DNS record updated successfully."
#else
#    echo "Failed to update DNS record:"
#    echo "$RESPONSE"
#fi