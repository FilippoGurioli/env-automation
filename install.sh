#!/usr/bin/env bash

set -euo pipefail # fail fast strategy

echo "Checking connectivity"
if ! ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
	echo "No connection, aborting bootstrap install, re-launch this script once there is connectivity"
	exit 1
else
	echo "Connected, starting bootstrap install"
fi

echo "Setting variables..."
export HOST="$1"
export USER="$2"
export PASSWORD="$3"
export BASE_URL="https://raw.githubusercontent.com/FilippoGurioli/env-automation/dev"
if grep -qEi 'qemu|vmware|virtualbox|kvm' /sys/class/dmi/id/sys_vendor 2>/dev/null; then
	export VM_ENV=1
else
	export VM_ENV=0
fi

echo "Downloading scripts..."
curl -fsSL "$BASE_URL/utils.sh" -o /mnt/root/utils.sh
curl -fsSL "$BASE_URL/bootstrap/install.sh" -o bootstrap.sh
curl -fsSL "$BASE_URL/bootstrap/post-install.sh" -o /mnt/root/post-bootstrap.sh
curl -fsSL "$BASE_URL/provision/install.sh" -o /mnt/root/provision.sh
curl -fsSL "$BASE_URL/provision/post-install.sh" -o /mnt/root/post-provision.sh

echo "Sourcing scripts..."
source /mnt/root/utils.sh
source ./bootstrap.sh

info "Launching arch-chroot scripts..."
arch-chroot /mnt /bin/bash -c "source /root/utils.sh && source /root/post-bootstrap.sh"
# arch-chroot /mnt /bin/bash -c "source /root/utils.sh && source /root/provision.sh"
# arch-chroot /mnt /bin/bash -c "source /root/utils.sh && source /root/post-provision.sh"

info "Cleaning up..."
rm /mnt/root/utils.sh
rm /bootstrap.sh
rm /mnt/root/post-bootstrap.sh
rm /mnt/root/provision.sh
rm /mnt/root/post-provision.sh

umount -R /mnt

if [ $VM_ENV -eq 1 ]; then
	info "VM detected, not rebooting."
else
	reboot
fi

exit 0