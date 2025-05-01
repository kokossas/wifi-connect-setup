#!/usr/bin/env bash
set -e
# wifi-connect-setup.sh
# Automates headless Raspberry Pi Wi-Fi Connect fallback setup on Debian Bookworm (64-bit)

# You might need to run this as root:
#   sudo ./wifi-connect-setup.sh

WIFI_CONNECT_VERSION="v4.11.82"
INSTALL_DIR_BIN="/usr/local/bin"
INSTALL_DIR_UI="/usr/local/share/wifi-connect-ui"
SERVICE_FILE="/etc/systemd/system/wifi-connect.service"

echo "1️⃣  Installing WiFi Connect binary..."
cd /tmp
curl -fsSL \
  "https://github.com/balena-io/wifi-connect/releases/download/${WIFI_CONNECT_VERSION}/wifi-connect-aarch64-unknown-linux-gnu.tar.gz" \
  | tar -xz
mv wifi-connect "${INSTALL_DIR_BIN}/"

echo "2️⃣  Installing WiFi Connect UI assets..."
curl -fsSL \
  "https://github.com/balena-io/wifi-connect/releases/download/${WIFI_CONNECT_VERSION}/wifi-connect-ui.tar.gz" \
  | tar -xz
mkdir -p "${INSTALL_DIR_UI}"
mv index.html asset-manifest.json static/ "${INSTALL_DIR_UI}/"

echo "3️⃣  Creating connectivity‐check script..."
cat > "${INSTALL_DIR_BIN}/wifi-check.sh" << 'EOF'
#!/usr/bin/env bash
# Wait up to 12s for upstream; then launch AP if none
max_wait=12; interval=3; elapsed=0
echo "Waiting up to $max_wait seconds for upstream connectivity…"
while [ "$elapsed" -lt "$max_wait" ]; do
  echo "Checking… ($elapsed s elapsed)"
  if ping -c1 8.8.8.8 &>/dev/null; then
    echo "Upstream detected; exiting."
    exit 0
  fi
  sleep "$interval"
  elapsed=$((elapsed + interval))
done
echo "No upstream; starting captive portal."
/usr/local/bin/wifi-connect \
  --portal-ssid "Spotipi Setup" \
  --portal-interface wlan0 \
  --ui-directory /usr/local/share/wifi-connect-ui
EOF
chmod +x "${INSTALL_DIR_BIN}/wifi-check.sh"

echo "4️⃣  Writing systemd service…"
cat > "${SERVICE_FILE}" << 'EOF'
[Unit]
Description=WiFi Connect fallback
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/wifi-check.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "5️⃣  Installing NetworkManager and disabling dhcpcd…"
apt update
apt install -y network-manager
systemctl disable dhcpcd || true

echo "6️⃣  Enabling service on boot…"
systemctl daemon-reload
systemctl enable wifi-connect.service

echo "🎉  Done! Reboot now to test fallback mode."
