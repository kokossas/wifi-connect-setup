# Setting Up WiFi Connect Fallback Mode on 64-bit Debian Bookworm Raspberry Pi **(Headless)**

These instructions are based on [balena-os/wifi-connect](https://github.com/balena-os/wifi-connect).  
They assume a fresh install and that NetworkManager is in use.

---

## Quick-Install Script


```bash
wget https://raw.githubusercontent.com/kokossas/wifi-connect-setup/main/wifi-connect-setup.sh
chmod +x wifi-connect-setup.sh
sudo ./wifi-connect-setup.sh

### How it works

- **Ping check**: one attempt to 8.8.8.8  
- **Exit if online**: does nothing, your Pi stays on your normal network  
- **Launch hotspot if offline**: SSID `Spotipi Setup` on `wlan0`  
- **Capture-portal UI**: served from `/usr/local/share/wifi-connect-ui` at [http://192.168.42.1](http://192.168.42.1)


What it does for you:

1. **Downloads & installs** the WiFi Connect binary (v4.11.82)  
2. **Fetches & deploys** the UI assets to `/usr/local/share/wifi-connect-ui`  
3. **Creates** the `/usr/local/bin/wifi-check.sh` wrapper that waits for upstream then launches the captive portal  
4. **Writes** a `wifi-connect.service` systemd unit and enables it on boot  
5. **Installs** NetworkManager (and disables any conflicting dhcpcd)  
6. **Reloads** systemd and turns the service on

Once it’s done, reboot:

```bash
sudo reboot
```

If no external network is found, you’ll see SSID **Spotipi Setup**. Connect any device and point your browser to [http://192.168.42.1](http://192.168.42.1) to finish Wi-Fi configuration.

---

