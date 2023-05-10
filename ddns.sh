#!/bin/bash

# ddns.sh

# Function to check if the IP address contains "Maxis" in its name
contains_maxis() {
    local ip_name=$(curl -s https://api.ipify.org?format=json | jq -r '.ip')  # Get the current IP address
    if [[ $ip_name == *"Maxis"* ]]; then
        return 0  # IP address contains "Maxis"
    else
        return 1  # IP address does not contain "Maxis"
    fi
}

# Echo step: Initiate warp-go o on root and selecting option 0 (exit)
echo "Initiating warp-go o on root and selecting option 0 (exit)"
echo "0" | warp-go o

# Check if the IP address contains "Maxis", wait if it doesn't
while ! contains_maxis; do
    sleep 5
done

# Echo step: Running cloudflare.sh and cloudflare2.sh in /root/cloudflare-ddns-updater
echo "Running cloudflare.sh and cloudflare2.sh in /root/cloudflare-ddns-updater"
cd /root/cloudflare-ddns-updater
./cloudflare.sh
./cloudflare2.sh

# Wait for 5 seconds
sleep 5

# Echo step: Running warp-go o in root
echo "Running warp-go o in root"
echo "0" | warp-go o

# Update crontab entry to schedule script every hour
(crontab -l ; echo "0 * * * * /root/ddns.sh") | crontab -

# Echo step: Script execution completed
echo "Script execution completed"
