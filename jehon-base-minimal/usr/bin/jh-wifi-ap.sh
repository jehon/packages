#!/usr/bin/env bash

set -e

IWIFI="wlp2s0"
echo "Using IWIFI: $IWIFI"

IWAN="$(ip a | grep LOWER_UP | grep -v "lo:" | cut -d ":" -f 2 | sed 's/ //g' )"
echo "Found IWAN:  $IWAN"


#
# Initial config
#
sudo wifi-ap.config set \
    debug=true \
    wifi.ssid=latitude \
    wifi.security-passphrase=kitditwa \
    share.disabled=true \
    wifi.country-code=BE \
    "share.network-interface=$IWAN" \
    "wifi.interface=$IWIFI"

stop() {
    #
    # Desactivate (on INT or on call)
    #
    echo "Disable it"
    sudo wifi-ap.config set disabled=true
}

trap stop INT
trap stop EXIT # Is this necessary ?

#
# Activate
#
echo "Activate it"
sudo wifi-ap.config set disabled=false

#
# Debug: config
#
# sudo journalctl -b -u snap.wifi-ap.management-service -n 100 --no-pager -f
# sudo wifi-ap.config get
# sudo wifi-ap.status

echo "Waiting to disable it"
read -r

stop
