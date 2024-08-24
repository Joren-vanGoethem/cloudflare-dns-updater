FROM alpine:latest

# Install packages
RUN apk --no-cache add curl bash

# Copy the update script to the container
COPY cloudflare-updater.sh /usr/local/bin/update-dns.sh

# Make the script executable
RUN chmod +x /usr/local/bin/update-dns.sh

# Set the script to run every 5 minutes
RUN echo "*/5 * * * * /usr/local/bin/update-dns.sh" > /etc/crontabs/root

# Start cron job in the foreground
CMD ["crond", "-f"]
