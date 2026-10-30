# Wi-Fi Manager for Debian 13

A simple, interactive Bash script for managing Wi-Fi connections on Debian 13 using NetworkManager. Designed for headless Linux systems, Raspberry Pi devices, and portable amateur radio projects.

Wi-Fi Manager makes it easy to scan for wireless networks, save connection profiles, configure passwords, and establish connection priorities without manually editing `wpa_supplicant.conf`.

## Features

- Scan for nearby Wi-Fi access points.
- Add and save Wi-Fi networks, even when they are out of range.
- Securely configure Wi-Fi passwords.
- Enable automatic Wi-Fi connections.
- Set connection priorities to determine preferred networks.
- View saved Wi-Fi profiles and active connections.
- Add connections without intentionally interrupting an active SSH session.

## Requirements

- Debian 13 (Trixie) or compatible Linux distribution
- NetworkManager (`nmcli`)
- Working Wi-Fi adapter
- Bash
- sudo privileges

## Installation

**1. Download the script** from this GitHub repository.

**2. Make the script executable:**

```bash
chmod +x wifi-manager.sh
```

**3. Optionally install it system-wide:**

```bash
sudo install -m 755 wifi-manager.sh /usr/local/bin/wifi-manager
```

## Usage

Run directly from the downloaded directory:

```bash
./wifi-manager.sh
```

Or, if installed system-wide:

```bash
wifi-manager
```

Follow the interactive menu to scan for networks, add Wi-Fi connections, view saved profiles, and configure connection priorities.

## Understanding Wi-Fi Connection Priorities

NetworkManager supports an **autoconnect priority** setting that determines which saved Wi-Fi connection is preferred when multiple configured networks are available.

**The higher the priority number, the greater the preference.**

### Example Wi-Fi Priority Configuration

| Rank | Wi-Fi Network | Priority |
|---|---|---|
| 1 | Mandalore1 | 200 |
| 2 | Crusaders Mobile | 99 |
| 3 | Mandalore City | 20 |
| 4 | OCSO | 5 |

In this example:

- **Mandalore1 (200):** Highest priority. Preferred whenever NetworkManager is selecting an available connection.
- **Crusaders Mobile (99):** Second choice if Mandalore1 is unavailable.
- **Mandalore City (20):** Third choice if the two higher-priority networks are unavailable.
- **OCSO (5):** Lowest priority, serving as a backup connection.

### Priority Rules

- Higher numbers indicate greater preference.
- Lower numbers indicate less preference.
- The default priority is `0`.
- Negative priority values are supported.
- The supported priority range is `-999` to `999`.
- When priorities are equal, NetworkManager uses other connection-selection factors, including the most recently connected profile.
- Priorities are applied when NetworkManager selects an automatic connection.

**Important:** NetworkManager does not necessarily disconnect an existing working Wi-Fi connection when a higher-priority network becomes available. Connection priority is primarily used when selecting a connection, such as during startup or reconnection.

### Setting Priorities Manually

To assign Mandalore1 a priority of 200:

```bash
sudo nmcli connection modify "Mandalore1" connection.autoconnect-priority 200
```

To assign Crusaders Mobile a priority of 99:

```bash
sudo nmcli connection modify "Crusaders Mobile" connection.autoconnect-priority 99
```

These changes are saved in NetworkManager's connection profiles.

### Viewing Connection Priorities

To display all saved profiles and their priority values:

```bash
nmcli -f NAME,AUTOCONNECT,AUTOCONNECT-PRIORITY connection show
```

Example output:

```text
NAME                          AUTOCONNECT  AUTOCONNECT-PRIORITY
netplan-wlan0-Mandalore City  yes          20
Crusaders Mobile              yes          99
Mandalore1                    yes          200
OCSO                          yes          5
```

### Recommended Priority Strategy

For portable Raspberry Pi and amateur radio applications, consider using increments of 10, 20, or 50 between network priorities.

This makes it easier to insert additional preferred networks later without reorganizing every connection.

For example:

- 200: Primary network
- 150: Secondary network
- 100: Mobile hotspot
- 50: Alternate network
- 10: Emergency backup

These values are examples, not fixed requirements.

## Adding Networks That Are Out of Range

One of the most useful features of Wi-Fi Manager is the ability to configure Wi-Fi connections before arriving at a location.

For example, you can configure your home Wi-Fi, mobile hotspot, repeater site, and club station networks while connected to your existing network.

When you move your device to another location, NetworkManager can automatically connect to a configured network that is available.

There is no need to manually edit configuration files each time you relocate the device.

## Important Notes

- This script is designed for systems using NetworkManager.
- Saved Wi-Fi connections are managed through NetworkManager rather than manually maintained `wpa_supplicant.conf` files.
- Adding a new connection does not immediately activate it.
- Automatic connections require valid credentials and compatible Wi-Fi security settings.
- Changing Wi-Fi settings remotely should be done carefully to avoid losing SSH access.
- Connection priorities do not guarantee immediate roaming between available wireless networks.

## Ideal Applications

Wi-Fi Manager is particularly useful for:

- Raspberry Pi projects
- Headless Debian Linux installations
- AllStarLink and APRS systems
- Portable amateur radio stations
- Mobile hotspots and field deployments
- Remote monitoring systems
- Devices frequently moved between network locations

## Author

**KD5FMU | Ham Radio Crusader**

Website: https://hamradiolife.org

YouTube: https://youtube.com/@hamradiocrusader

**Ham On Y'all!!**

