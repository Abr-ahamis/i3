#!/usr/bin/env bash

SAMPLE_SECS=0.9

# --- Convert speed ---
human_rate() {
    local bps=$1
    if (( bps >= 1048576 )); then
        printf "%.1f MB/s" "$(echo "$bps / 1048576" | bc -l)"
    else
        printf "%.0f KB/s" "$(echo "$bps / 1024" | bc -l)"
    fi
}

# --- Interface detection (VPN → WiFi → any UP) ---
pick_iface() {
    # 1. VPN (tun0)
    if ip -4 addr show tun0 | grep -q "inet "; then
        echo "tun0"
        return
    fi

    # 2. WLAN
    if ip -4 addr show wlan0 | grep -q "inet "; then
        echo "wlan0"
        return
    fi

    # 3. Any interface that is UP and has IP
    for iface in $(ls /sys/class/net); do
        [[ "$iface" = "lo" ]] && continue
        grep -q "up" "/sys/class/net/$iface/operstate" || continue
        if ip -4 addr show "$iface" | grep -q "inet "; then
            echo "$iface"
            return
        fi
    done
}

INTERFACE=$(pick_iface)
[ -z "$INTERFACE" ] && { echo "No net"; exit 0; }

IP=$(ip -4 addr show "$INTERFACE" | awk '/inet /{print $2}' | cut -d/ -f1)

# --- Speed sampling ---
RX1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
sleep "$SAMPLE_SECS"
RX2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

RX_BPS=$(( (RX2 - RX1) / SAMPLE_SECS ))
TX_BPS=$(( (TX2 - TX1) / SAMPLE_SECS ))

DOWN=$(human_rate "$RX_BPS")
UP=$(human_rate "$TX_BPS")

# Output
echo "↑ $UP   ↓ $DOWN | $IP"
