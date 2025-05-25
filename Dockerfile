# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Install cron
RUN apt-get update && apt-get install -y cron && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the Python script and requirements
COPY requirements.txt .
COPY cloudflare_updater.py .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy and set up the entrypoint script
COPY cronjob.sh .
RUN chmod +x cronjob.sh

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Set the entrypoint
ENTRYPOINT ["./cronjob.sh"]