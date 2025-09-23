#!/bin/bash

STATUS=$(systemctl is-active libvirtd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "⚠️  No .env file found at $SCRIPT_DIR/.env"
    exit 1
fi

if [ "$STATUS" != "active" ]; then
	sudo systemctl enable --now libvirtd
fi

"$SCRIPT_DIR/lib/wipe-vm.sh" && "$SCRIPT_DIR/lib/build-vm.sh" 

LOGPATH="$SCRIPT_DIR/logs/$(date +'%Y-%m-%d_%H-%M-%S').log"

touch "$LOGPATH"

"$SCRIPT_DIR/lib/launch-install.sh" "$HOST" "$USER" "$PASSWORD" > "$LOGPATH" 2>&1

virsh shutdown arch
sleep 5 # waiting to shutdown correctly
virsh start arch
"$SCRIPT_DIR/open-vm.sh"
