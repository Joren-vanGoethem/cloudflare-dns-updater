#!/bin/bash

# Default to every 5 minutes if CRON_TIMER is not set
CRON_TIMER=${CRON_TIMER:-"*/5 * * * *"}

PYTHON_PATH=$(which python)

# Create the cron job with the environment variable
echo "$CRON_TIMER $PYTHON_PATH /app/cloudflare_updater.py >> /var/log/cron.log 2>&1" > /etc/cron.d/cloudflare-cron

# Give execution rights on the cron job and apply it
chmod 0644 /etc/cron.d/cloudflare-cron
crontab /etc/cron.d/cloudflare-cron

# Start cron and follow the logs
cron && tail -f /var/log/cron.log