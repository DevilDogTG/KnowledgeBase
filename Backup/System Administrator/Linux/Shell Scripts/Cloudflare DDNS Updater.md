---
layout: default
---
# Cloudflare DDNS Updater via shell scrript

ref: [https://dev.to/ordigital/cloudflare-ddns-on-linux-4p0d](Referrence)

require package to install

```shell
apt install jq curl
```

create shell script

```shell
nano /usr/local/bin/ddns
```

use following script

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

replace `DNS_ZONE_ID` from `zone id` in cloudflare domain dashboard
`DNS_ENTRY_ID` can get from cloudflare api [https://developers.cloudflare.com/api/operations/dns-records-for-a-zone-list-dns-records](Cloudflare API)
`YOUR_TOKEN_HERE` create with permission `Zone.Edit`

call cloudflare

```shell
curl --request GET \
  --url https://api.cloudflare.com/client/v4/zones/zone_id/dns_records \
  --header 'Content-Type: application/json' \
  --header 'Authorization: Bearer YOUR_TOKEN_HERE'
```

after that update script to executable

```shell
chmode 755 /usr/local/bin/ddns
```

update crontab

```shell
crontab -e
```

schedule every minute

```txt
* * * * * /usr/local/bin/ddns > /dev/null 2>&1
```

Done.
