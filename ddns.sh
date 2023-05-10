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

echo "Update crontab entry to schedule script every hour"
(crontab -l ; echo "0 * * * * /root/ddns.sh") | crontab -

echo "Script execution completed"
