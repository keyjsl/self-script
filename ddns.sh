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

echo "Running warp-go o in root"
echo "0" | warp-go o

echo "Fetch current IPv4 address from network interface"
network_interface=$(ip -4 route show default | awk '/default/ {print $5}')
current_ip=$(ip -4 addr show dev "$network_interface" | awk '/inet / {print $2}' | cut -d '/' -f1)

echo "Resolve IP address to domain"
ip_domain=$(dig -x "$current_ip" +short)

echo "Checking if IPv4 address belongs to Cloudflare"
if [[ $ip_domain == *"cloudflare"* ]]; then
    echo "IPv4 address belongs to Cloudflare"
else
    echo "IPv4 address does not belong to Cloudflare, running warp-go o in root again"

    echo "Re-run warp-go o until the IP address belongs to Cloudflare"
    while [[ $ip_domain != *"cloudflare"* ]]; do
        echo "Running warp-go o in root"
        echo "0" | warp-go o
        network_interface=$(ip -4 route show default | awk '/default/ {print $5}')
        current_ip=$(ip -4 addr show dev "$network_interface" | awk '/inet / {print $2}' | cut -d '/' -f1)
        ip_domain=$(dig -x "$current_ip" +short)
    done

    echo "IPv4 address now belongs to Cloudflare"
fi

echo "Check if crontab entry already exists"
if crontab -l | grep -q "/root/ddns.sh"; then
    echo "Crontab entry already exists"
else
    # Update crontab entry to schedule script every hour
    (crontab -l ; echo "0 * * * * /root/ddns.sh") | crontab -
    echo "Crontab entry added"
fi

echo "Script execution completed"
