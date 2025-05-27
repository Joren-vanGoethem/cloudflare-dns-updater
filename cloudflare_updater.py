import os
import socket
from dataclasses import dataclass
from datetime import datetime
from typing import Optional, List, Dict

import requests
from dotenv import load_dotenv

# loading variables from .env file
if not os.getenv('CF_API_KEY'):
    load_dotenv()


# Load environment variables
CF_API_KEY: str = os.getenv("CF_API_KEY")
CF_ZONE_ID: str = os.getenv("CF_ZONE_ID")
CF_RECORD_ID: str = os.getenv("CF_RECORD_ID")
CF_EMAIL: str = os.getenv("CF_EMAIL")
CF_RECORD_NAME: str = os.getenv("CF_RECORD_NAME")
CF_RECORD_TYPE: str = os.getenv("CF_RECORD_TYPE", "A")
CF_TTL: int = int(os.getenv("CF_TTL", 360))
CF_PROXIED: bool = os.getenv("CF_PROXIED", "false").lower() in ('true', '1', 'yes')


print(CF_ZONE_ID)

@dataclass
class CloudflareDNSRecord:
    id: str
    name: str
    type: str
    content: str
    proxiable: bool
    proxied: bool
    ttl: int
    settings: Dict
    meta: Dict
    comment: Optional[str]
    tags: List[str]
    created_on: datetime
    modified_on: datetime

    @classmethod
    def from_dict(cls, data: dict) -> 'CloudflareDNSRecord':
        # Convert ISO format strings to datetime objects
        created_on = datetime.fromisoformat(data['created_on'].replace('Z', '+00:00'))
        modified_on = datetime.fromisoformat(data['modified_on'].replace('Z', '+00:00'))

        return cls(
            id=data['id'],
            name=data['name'],
            type=data['type'],
            content=data['content'],
            proxiable=data['proxiable'],
            proxied=data['proxied'],
            ttl=data['ttl'],
            settings=data['settings'],
            meta=data['meta'],
            comment=data['comment'],
            tags=data['tags'],
            created_on=created_on,
            modified_on=modified_on
        )


def get_domain_ip(domain):
    try:
        # Resolve the domain name to its IP address
        return socket.gethostbyname(domain)
    except Exception as e:
        print(f"Error resolving domain: {e}")
        return None


def get_my_public_ip():
    try:
        # Fetch the public IP address
        response = requests.get("https://api.ipify.org?format=json")
        response.raise_for_status()
        return response.json().get("ip")
    except requests.RequestException as e:
        print(f"Error fetching public IP: {e}")
        return None


def get_cloudflare_record(record_type: str = "A") -> Optional[CloudflareDNSRecord]:
    url = f"https://api.cloudflare.com/client/v4/zones/{CF_ZONE_ID}/dns_records"
    headers = {
        "X-Auth-Email": CF_EMAIL,
        "X-Auth-Key": CF_API_KEY
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        json_records = response.json().get("result", [])
        cloudflare_records = [CloudflareDNSRecord.from_dict(json_records) for json_records in json_records]
        record: CloudflareDNSRecord = next(
            (record for record in cloudflare_records if record.type == record_type),
            None)

        return record
    except requests.RequestException as e:
        print(f"Error fetching Cloudflare DNS record: {e}")
        return None


def update_cloudflare_dns(ip):
    url = f"https://api.cloudflare.com/client/v4/zones/{CF_ZONE_ID}/dns_records/{CF_RECORD_ID}"
    headers = {
        "X-Auth-Email": CF_EMAIL,
        "X-Auth-Key": CF_API_KEY,
        "Content-Type": "application/json"
    }
    data = {
        "type": CF_RECORD_TYPE,
        "name": CF_RECORD_NAME,
        "content": ip,
        "ttl": int(CF_TTL),
        "proxied": bool(CF_PROXIED)
    }
    try:
        response = requests.put(url, json=data, headers=headers)
        response.raise_for_status()
        result = response.json()

        if result.get("success"):
            print(f"DNS record updated successfully: {ip}")
            return True
        else:
            errors = result.get("errors", [])
            messages = [error.get("message", "Unknown error") for error in errors]
            print(f"Failed to update DNS record: {messages}")
            return False

    except requests.RequestException as e:
        print(f"Error updating Cloudflare DNS: {e}")
        if hasattr(e.response, 'json'):
            try:
                error_details = e.response.json()
                print(f"Error details: {error_details}")
            except ValueError:
                print(f"Response text: {e.response.text}")
        return False

if __name__ == "__main__":
    # Get the current public IP
    public_ip = get_my_public_ip()
    if not public_ip:
        print("Failed to fetch public IP. Exiting.")
        exit(1)

    print("current public ip:", public_ip)

    record_ip = get_cloudflare_record(CF_RECORD_TYPE).content

    if record_ip == "" or record_ip is None:  # TODO: check if empty or none or whateva
        record_ip = get_domain_ip(CF_RECORD_NAME)

    if record_ip == public_ip:
        print("No update needed. IP address has not changed.")
    else:
        print(f"Updating DNS record. Current IP: {record_ip}, New IP: {public_ip}")
        update_cloudflare_dns(public_ip)
