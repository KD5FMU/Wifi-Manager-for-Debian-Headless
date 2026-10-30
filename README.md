# Wi-Fi Manager for Debian 13

A simple, interactive Bash script for managing Wi-Fi connections on Debian 13 using NetworkManager. Designed for headless Linux systems, including Raspberry Pi devices.

## Features
- Scan for nearby Wi-Fi access points.
- Add and save Wi-Fi networks, even when out of range.
- Securely configure Wi-Fi passwords.
- Enable automatic Wi-Fi connections.
- Set Wi-Fi connection priorities.
- View saved Wi-Fi profiles.
- Manage networks without intentionally interrupting active SSH connections.

## Requirements
- Debian 13 (Trixie) or compatible Linux distribution
- NetworkManager (`nmcli`)
- Wi-Fi adapter
- sudo privileges

## Installation

**1. Download the script** from this GitHub repository to your Debian system.

**2. Make the script executable:**

```bash
chmod +x wifi-manager.sh
```

**3. Optionally install it system-wide:**

```bash
sudo install -m 755 wifi-manager.sh /usr/local/bin/wifi-manager
```

## Usage

If running directly from the downloaded directory:

```bash
./wifi-manager.sh
```

If installed system-wide:

```bash
wifi-manager
```

Follow the interactive menu to scan for nearby access points, configure additional Wi-Fi networks, and manage connection priorities.

## Notes

- Wi-Fi networks can be configured even when they are not currently in range.
- Saved networks can automatically connect when available.
- Higher connection priorities are preferred when NetworkManager selects an automatic connection.
- Adding a saved network does not immediately switch your active Wi-Fi connection.

## Ideal For

Raspberry Pi projects, portable Linux systems, amateur radio applications, remote installations, and headless devices that frequently move between Wi-Fi networks.

**Created by KD5FMU | Ham Radio Crusader**

Website: https://hamradiolife.org

**Ham On Y'all!!**
