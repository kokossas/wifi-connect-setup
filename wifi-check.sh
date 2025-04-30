#!/bin/bash
# Wait up to 12 seconds checking for upstream connectivity
max_wait=12
interval=3
elapsed=0

echo "Waiting up to $max_wait seconds for upstream connectivity to stabilize..."
while [ $elapsed -lt $max_wait ]; do
    echo "Checking connectivity... ($elapsed sec elapsed)"
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "Upstream connectivity detected; not launching hotspot."
        exit 0
    fi
    sleep $interval
    elapsed=$((elapsed + interval))
done

echo "No upstream connectivity detected; launching WiFi Connect..."
/usr/local/bin/wifi-connect --portal-ssid "Spotipi Setup" --portal-interface wlan0 --ui-directory /usr/local/share/wifi-connect-ui
