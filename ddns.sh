#!/bin/bash

echo "ddns.sh"
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )

if echo "$ISP" | grep -q "Cloudflare"; then
    echo "IPv4 address belongs to Cloudflare"
elif echo "$ISP" | grep -q "Maxis"; then
    echo "IPv4 address belongs to Maxis, skipping warp-go o"
else
    echo "IPv4 address does not belong to Cloudflare, running warp-go o in root"

    echo "Running warp-go o in root"
    echo "0" | warp-go o
    sleep 5

echo "Running cloudflare.sh and cloudflare2.sh in /root/cloudflare-ddns-updater"
cd /root/cloudflare-ddns-updater
./cloudflare.sh
./cloudflare2.sh

echo "Wait for 5 seconds"
sleep 5

echo "Running warp-go o in root"
echo "0" | warp-go o

echo "Wait for 5 seconds"
sleep 5

echo "Checking if IPv4 address belongs to Cloudflare"
if echo "$ISP" | grep -q "Cloudflare"; then
    echo "IPv4 address belongs to Cloudflare"
else
    echo "IPv4 address does not belong to Cloudflare, running warp-go o in root again"

    echo "Re-run warp-go o until the IP address belongs to Cloudflare"
    while false; do
        echo "Running warp-go o in root"
        echo "0" | warp-go o
        sleep 5
        current_ip=$(ip -4 addr show dev "$network_interface" | awk '/inet / {print $2}' | cut -d '/' -f1)

        if echo "$ISP" | grep -q "Cloudflare"; then
            echo "IPv4 address now belongs to Cloudflare"
            break
        fi
    done
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
