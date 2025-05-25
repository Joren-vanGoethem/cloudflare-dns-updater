# Cloudflare DNS Updater

This Docker container automatically updates your Cloudflare DNS records with your current IP address. It's ideal for
non-static IP setups like normal residential connections where your IP changes frequently, and you want to keep your
domain updated on Cloudflare.

## Features

- Automatically updates the specified DNS record with your current public IP.
- Configurable via environment variables.
- Lightweight and runs on a schedule using cron.
- Supports multiple instances for managing multiple domains or DNS records.

## Getting Started

### Prerequisites

- Docker and Docker Compose installed on your server.
- Cloudflare API key, Zone ID, and DNS Record ID.

### Environment Variables

Configure the container with the following environment variables:

- **`CF_API_KEY`**: Your Cloudflare API key.
- **`CF_EMAIL`**: Your Cloudflare account email.
- **`CF_ZONE_ID`**: The Cloudflare Zone ID of your domain.
- **`CF_RECORD_ID`**: The ID of the DNS record you want to update.
- **`CF_RECORD_NAME`**: The DNS record name (e.g., `example.com`).
- **`CF_RECORD_TYPE`**: (Optional) The type of DNS record (default is `A`).
- **`CF_TTL`**: (Optional) The TTL of the DNS record (default is `360` seconds).
- **`CF_PROXIED`**: (Optional) Whether the record is proxied by Cloudflare (default is `true`).
- **`CRON_TIMER`**: (Optional) overrides the 5 minute cron timer

To find your Zone ID through the web UI head to the Cloudflare Dashboard, select your domain and look under the API selection of the sidebar, you’ll see your account ID and zone ID.

To find your record ID, edit that record manually in the Cloudflare Dashboard, then Save. It will show up in the Audit Log at the top of dash.cloudflare.com with the Record ID.

### Example Docker Compose File

Here's an example `docker-compose.yml` file that sets up the Cloudflare DNS updater:

```yaml
services:
  cloudflare-dns-updater:
    image: your-dockerhub-username/cloudflare-dns-updater:latest
    container_name: cloudflare-dns-updater
    environment:
      - CF_API_KEY=your_cloudflare_api_key
      - CF_EMAIL=your_email@example.com
      - CF_ZONE_ID=your_zone_id
      - CF_RECORD_ID=your_record_id
      - CF_RECORD_NAME=your_domain.com
      - CF_RECORD_TYPE=A
      - CF_TTL=120
      - CF_PROXIED=true
      - CRON_TIMER="*/15 * * * *"
    restart: unless-stopped
```

### Deploying with Docker Compose

1. **Clone the repository** (if not done already):
   ```bash
   git clone https://github.com/yourusername/cloudflare-dns-updater.git
   cd cloudflare-dns-updater
   ```

2. **Create your `docker-compose.yml`** in the root of the repository using the example provided above.

3. **Start the container**:
   ```bash
   docker-compose up -d
   ```

4. The container will now run in the background, updating your DNS record every 5 minutes. You can check the logs with:

   ```bash
   docker-compose logs -f
   ```

### Managing Multiple Domains

To manage multiple domains or DNS records, you can extend your `docker-compose.yml` to include additional services:

```yaml
services:
  domain1-updater:
    image: ghcr.io/joren-vangoethem/cloudflare-dns-updater:latest
    container_name: domain1-updater
    environment:
      - CF_API_KEY=your_cloudflare_api_key
      - CF_EMAIL=your_email@example.com
      - CF_ZONE_ID=your_zone_id_for_domain1
      - CF_RECORD_ID=your_record_id_for_domain1
      - CF_RECORD_NAME=domain1.com
      - CF_RECORD_TYPE=A
      - CF_TTL=120
      - CF_PROXIED=true
    restart: unless-stopped

  domain2-updater:
    image: ghcr.io/joren-vangoethem/cloudflare-dns-updater:latest
    container_name: domain2-updater
    environment:
      - CF_API_KEY=your_cloudflare_api_key
      - CF_EMAIL=your_email@example.com
      - CF_ZONE_ID=your_zone_id_for_domain2
      - CF_RECORD_ID=your_record_id_for_domain2
      - CF_RECORD_NAME=domain2.com
      - CF_RECORD_TYPE=A
      - CF_TTL=120
      - CF_PROXIED=true
    restart: unless-stopped
```

### Notes

- **Cron Schedule**: The script runs every 5 minutes by default. You can modify this in the `Dockerfile` or by creating
  a custom container with your preferred schedule.

### Contributing

Feel free to open issues or submit pull requests if you have any improvements or suggestions.
