#!/bin/bash

echo "ddns.sh"

echo "Initiating warp-go o on root and selecting option 0 (exit)"
echo "0" | warp-go o

echo "Running cloudflare.sh and cloudflare2.sh in /root/cloudflare-ddns-updater"
cd /root/cloudflare-ddns-updater
./cloudflare.sh
./cloudflare2.sh

echo "Wait for 5 seconds"
sleep 5

echo “Function to check if IP address belongs to Cloudflare”
ip_belongs_to_cloudflare() {
    local ip_address=$(curl -sS https://api.ipify.org)
    if [[ $ip_address == *"Cloudflare"* ]]; then
        return 0  # IP address belongs to Cloudflare
    else
        return 1  # IP address does not belong to Cloudflare
    fi
}

echo "Running warp-go o in root"
echo "0" | warp-go o

echo "Checking IP address for Cloudflare"
while ! ip_belongs_to_cloudflare; do
    echo "IP address does not belong to Cloudflare, running warp-go o in root again"
    echo "0" | warp-go o
    sleep 5  echo "Wait for 5 seconds"
done

echo "IP address belongs to Cloudflare"

echo "Check if crontab entry already exists"
if crontab -l | grep -q "/root/ddns.sh"; then
    echo "Crontab entry already exists"
else
    # Update crontab entry to schedule script every hour
    (crontab -l ; echo "0 * * * * /root/ddns.sh") | crontab -
    echo "Crontab entry added"
fi

echo "Script execution completed"
