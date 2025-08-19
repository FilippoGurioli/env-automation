#!/bin/bash

STATUS=$(systemctl is-active libvirtd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$STATUS" != "active" ]; then
	sudo systemctl enable --now libvirtd
fi

"$SCRIPT_DIR/lib/wipe-vm.sh" && "$SCRIPT_DIR/lib/build-vm.sh" && "$SCRIPT_DIR/lib/launch-install.sh" "$@"

virsh shutdown arch
sleep 5 # waiting to shutdown correctly
virsh start arch
"$SCRIPT_DIR/open-vm.sh"
