---
title: "Cloudflare DDNS Updater via Shell Script"
author: DevilDogTG
date: 2025-06-01 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, shell script, cloudflare, ddns, networking]
---

Keep your Cloudflare DNS records up to date with your current external IP via a shell script.

**Reference:** [Cloudflare DDNS on Linux](https://dev.to/ordigital/cloudflare-ddns-on-linux-4p0d)

## Prerequisites

```shell
apt install jq curl
```

## Create the Script

```shell
nano /usr/local/bin/ddns
```

Use the following script:

```shell
#!/bin/bash

# Check for current external IP
IP=`dig +short txt ch whoami.cloudflare @1.0.0.1| tr -d '"'`

# Set Cloudflare API
URL="https://api.cloudflare.com/client/v4/zones/DNS_ZONE_ID/dns_records/DNS_ENTRY_ID"
TOKEN="YOUR_TOKEN_HERE"
NAME="DNS_ENTRY_NAME"

# Connect to Cloudflare
cf() {
  curl -X ${1} "${URL}" \
       -H "Content-Type: application/json" \
       -H "Authorization: Bearer ${TOKEN}" \
       ${2} ${3}
}

# Get current DNS data
RESULT=$(cf GET)
IP_CF=$(jq -r '.result.content' <<< ${RESULT})

# Compare IPs
if [ "$IP" = "$IP_CF" ]; then
    echo "No change."
else
    RESULT=$(cf PUT --data "{\"type\":\"A\",\"name\":\"${NAME}\",\"content\":\"${IP}\"}")
    echo "DNS updated."
fi
```

Replace the placeholders:

| Variable | Where to find |
|---|---|
| `DNS_ZONE_ID` | Zone ID in the Cloudflare domain dashboard |
| `DNS_ENTRY_ID` | Get from [Cloudflare API — List DNS Records](https://developers.cloudflare.com/api/operations/dns-records-for-a-zone-list-dns-records) |
| `YOUR_TOKEN_HERE` | Create an API token with `Zone.Edit` permission |

To get the DNS entry ID via API:

```shell
curl --request GET \
  --url https://api.cloudflare.com/client/v4/zones/zone_id/dns_records \
  --header 'Content-Type: application/json' \
  --header 'Authorization: Bearer YOUR_TOKEN_HERE'
```

## Setup

Make the script executable:

```shell
chmod 755 /usr/local/bin/ddns
```

Edit crontab to run every minute:

```shell
crontab -e
```

Add:

```
* * * * * /usr/local/bin/ddns > /dev/null 2>&1
```

Done.
