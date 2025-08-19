#!/bin/bash

STATUS=$(systemctl is-active libvirtd)

if [ "$STATUS" != "active" ]; then
	sudo systemctl enable --now libvirtd
fi

./lib/wipe-vm.sh && ./lib/build-vm.sh && ./lib/launch-custom-install.sh $1 $2
