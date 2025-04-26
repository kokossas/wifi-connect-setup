
# Setting Up WiFi Connect Fallback Mode on 64-bit Debian Bookworm Raspberry Pi **(Headless)**

These instructions are based on [balena-os/wifi-connect](https://github.com/balena-os/wifi-connect).
They assume a fresh install and that NetworkManager is in use.

---

## 1. Install the WiFi Connect Binary

Open a terminal and change to your home directory:

```bash
cd ~
```

Download and extract the AArch64 binary:

```bash
curl -fsSL https://github.com/balena-io/wifi-connect/releases/download/v4.11.82/wifi-connect-aarch64-unknown-linux-gnu.tar.gz | tar -xz
```

Move the binary to a location in your PATH:

```bash
sudo mv wifi-connect /usr/local/bin/
```

---

## 2. Install the WiFi Connect UI Assets

Download and extract the UI assets:

```bash
cd ~
curl -fsSL https://github.com/balena-io/wifi-connect/releases/download/v4.11.82/wifi-connect-ui.tar.gz | tar -xz
```

Create the target directory and move the UI files:

```bash
sudo mkdir -p /usr/local/share/wifi-connect-ui
sudo mv index.html asset-manifest.json static/ /usr/local/share/wifi-connect-ui/
```

(Optional) Verify the files:

```bash
ls -l /usr/local/share/wifi-connect-ui
```

---

## 3. Create the `wifi-check.sh` Script

Create and edit the script:

```bash
sudo nano /usr/local/bin/wifi-check.sh
```

Paste the following:

```bash
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
```

Save and exit, then make it executable:

```bash
sudo chmod +x /usr/local/bin/wifi-check.sh
```

---

## 4. Create a systemd Service

Create the service file:

```bash
sudo nano /etc/systemd/system/wifi-connect.service
```

Paste:

```ini
[Unit]
Description=WiFi Connect (Fallback Mode)
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/wifi-check.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Save and exit.

---

## 5. Prepare the Network Environment

Ensure NetworkManager is installed:

```bash
sudo apt install network-manager
```

Disable any conflicting services (e.g., `dhcpcd`) if necessary.

---

## 6. Enable and Test the Service

Enable the service:

```bash
sudo systemctl enable wifi-connect.service
```

Reboot the Pi:

```bash
sudo reboot
```

Without upstream connectivity, the Pi will start fallback mode. Look for SSID: `Spotipi Setup`.

Connect a device and open [http://192.168.42.1](http://192.168.42.1) to access the portal.
