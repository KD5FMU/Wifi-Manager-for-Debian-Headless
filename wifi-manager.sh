#!/usr/bin/env bash
# Wi-Fi profile manager for headless Debian using NetworkManager.
# Saves WPA2/WPA3-Personal connections without activating them.
set -u

IFACE="${WIFI_INTERFACE:-wlan0}"

if ! command -v nmcli >/dev/null 2>&1; then
    echo "Error: nmcli is not installed. This script requires NetworkManager."
    exit 1
fi
if [[ "$(nmcli -t -f RUNNING general 2>/dev/null)" != "running" ]]; then
    echo "Error: NetworkManager is not running."
    exit 1
fi
if ! nmcli -t -f DEVICE device status | grep -Fxq "$IFACE"; then
    echo "Error: Wi-Fi interface '$IFACE' was not found."
    exit 1
fi

pause() { echo; read -r -p "Press Enter to return to the menu..." _; }

scan_networks() {
    echo; echo "Nearby Wi-Fi networks on $IFACE:"
    nmcli -f IN-USE,SSID,SIGNAL,SECURITY device wifi list ifname "$IFACE" --rescan yes
}

list_profiles() {
    echo; echo "Saved connection profiles (passwords hidden):"
    nmcli -f NAME,TYPE,AUTOCONNECT connection show
    echo; echo "Currently active:"
    nmcli -f NAME,TYPE,DEVICE connection show --active
}

add_network() {
    local ssid profile hidden priority password confirm length
    echo
    read -r -p "Wi-Fi network name (SSID, exact spelling): " ssid
    if [[ -z "$ssid" ]]; then echo "SSID cannot be blank."; return; fi
    read -r -p "Profile name [${ssid}]: " profile
    profile="${profile:-$ssid}"
    if nmcli -g connection.id connection show "$profile" >/dev/null 2>&1; then
        echo "A profile named '$profile' already exists. No changes made."
        echo "Use the existing profile, or choose a different profile name."
        return
    fi
    read -r -p "Is this network hidden (not broadcasting SSID)? [y/N]: " hidden
    read -r -p "Auto-connect priority (higher wins when choosing a connection) [0]: " priority
    priority="${priority:-0}"
    if ! [[ "$priority" =~ ^-?[0-9]+$ ]] || (( priority < -999 || priority > 999 )); then
        echo "Priority must be an integer from -999 to 999."; return
    fi
    echo "This menu supports WPA2/WPA3-Personal with a password (not enterprise or open Wi-Fi)."
    read -r -s -p "Wi-Fi password (input hidden): " password; echo
    read -r -s -p "Repeat Wi-Fi password: " confirm; echo
    if [[ "$password" != "$confirm" ]]; then
        echo "Passwords do not match. No changes made."; unset password confirm; return
    fi
    length=${#password}
    if ! { (( length >= 8 && length <= 63 )) || { (( length == 64 )) && [[ "$password" =~ ^[[:xdigit:]]+$ ]]; }; }; then
        echo "WPA-Personal password must be 8-63 characters or 64 hexadecimal digits."
        unset password confirm; return
    fi
    unset confirm
    echo "Saving '$profile' for SSID '$ssid' (will NOT connect now)..."
    if ! sudo nmcli connection add type wifi ifname "$IFACE" con-name "$profile" ssid "$ssid" \
         wifi-sec.key-mgmt wpa-psk connection.autoconnect no >/dev/null; then
        echo "Failed to create profile."; unset password; return
    fi
    local hidden_setting=no
    [[ "$hidden" =~ ^[Yy]$ ]] && hidden_setting=yes
    if sudo nmcli connection modify "$profile" \
        wifi-sec.psk "$password" \
        802-11-wireless.hidden "$hidden_setting" \
        connection.autoconnect-priority "$priority" \
        connection.autoconnect yes; then
        echo "Saved successfully. It can auto-connect later when available."
    else
        echo "Could not finish profile; removing incomplete profile."
        sudo nmcli connection delete "$profile" >/dev/null
    fi
    unset password
}

change_priority() {
    local profile priority
    echo; nmcli -f NAME,TYPE,AUTOCONNECT connection show
    echo
    read -r -p "Exact profile name to change: " profile
    [[ -z "$profile" ]] && return
    if ! nmcli -g connection.id connection show "$profile" >/dev/null 2>&1; then
        echo "Profile not found."; return
    fi
    read -r -p "New priority (-999 to 999): " priority
    if ! [[ "$priority" =~ ^-?[0-9]+$ ]] || (( priority < -999 || priority > 999 )); then
        echo "Invalid priority."; return
    fi
    if sudo nmcli connection modify "$profile" connection.autoconnect-priority "$priority"; then
        echo "Priority updated. No network switch was requested."
    fi
}

while true; do
    echo
    echo "========== Wi-Fi Manager ($IFACE) =========="
    echo "1) Scan nearby Wi-Fi networks"
    echo "2) Add a Wi-Fi network (including out-of-range networks)"
    echo "3) Show saved connections and active connection"
    echo "4) Change auto-connect priority"
    echo "5) Exit"
    read -r -p "Choose 1-5: " choice
    case "$choice" in
        1) scan_networks; pause ;;
        2) add_network; pause ;;
        3) list_profiles; pause ;;
        4) change_priority; pause ;;
        5) exit 0 ;;
        *) echo "Choose a number from 1 to 5." ;;
    esac
done
