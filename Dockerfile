FROM alpine:latest

# Install packages
RUN apk --no-cache add curl bash

# Set default cron timer to 5 minutes
ENV CRON_TIMER="*/5 * * * *"

# Copy the update script to the container
COPY cloudflare-updater.sh /usr/local/bin/update-dns.sh

# Make the script executable
RUN chmod +x /usr/local/bin/update-dns.sh

# Set the script to run based on the CRON_TIMER environment variable
RUN echo "$CRON_TIMER /usr/local/bin/update-dns.sh" > /etc/crontabs/root

# Start cron job in the foreground
CMD ["crond", "-f"]