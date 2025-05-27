#!/bin/bash

# Default to every 5 minutes if CRON_TIMER is not set
CRON_TIMER=${CRON_TIMER:-"*/5 * * * *"}

PYTHON_PATH=$(which python)

# Create the cron job with all the required environment variables
cat > /etc/cron.d/cloudflare-cron << EOF
CF_API_KEY=$CF_API_KEY
CF_EMAIL=$CF_EMAIL
CF_ZONE_ID=$CF_ZONE_ID
CF_RECORD_ID=$CF_RECORD_ID
CF_RECORD_NAME=$CF_RECORD_NAME
CF_RECORD_TYPE=$CF_RECORD_TYPE
CF_TTL=$CF_TTL
CF_PROXIED=$CF_PROXIED

$CRON_TIMER root $PYTHON_PATH /app/cloudflare_updater.py >> /var/log/cron.log 2>&1
EOF

# Give execution rights on the cron job and apply it
chmod 0644 /etc/cron.d/cloudflare-cron
crontab /etc/cron.d/cloudflare-cron

# Start cron and follow the logs
cron && tail -f /var/log/cron.log