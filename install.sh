#!/usr/bin/env bash

set -euo pipefail # fail fast strategy

# Checking connectivity
info "Checking connectivity"
if ! ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
	error "No connection, aborting bootstrap install, re-launch this script once there is connectivity"
	exit 1
else
	info "Connected, starting bootstrap install"
fi

# Setting variables
export HOST="$1"
export USER="$2"
export PASSWORD="$3"
export BASE_URL="https://raw.githubusercontent.com/FilippoGurioli/env-automation/dev"
if grep -qEi 'qemu|vmware|virtualbox|kvm' /sys/class/dmi/id/sys_vendor 2>/dev/null; then
	export VM_ENV=1
else
	export VM_ENV=0
fi

# Downloading scripts
curl -fsSL "$BASE_URL/utils.sh" -o /mnt/utils.sh
curl -fsSL "$BASE_URL/bootstrap/install.sh" -o bootstrap.sh
curl -fsSL "$BASE_URL/bootstrap/post-install.sh" -o /mnt/post-bootstrap.sh
curl -fsSL "$BASE_URL/provision/install.sh" -o /mnt/provision.sh
curl -fsSL "$BASE_URL/provision/post-install.sh" -o /mnt/post-provision.sh

# Sourcing scripts as ISO root
source /mnt/utils.sh
source ./bootstrap.sh

# Running commands in system root
arch-chroot /mnt /bin/bash -c "source /utils.sh && /post-bootstrap.sh"
arch-chroot /mnt /bin/bash -c "source /utils.sh && /provision.sh"
arch-chroot /mnt /bin/bash -c "source /utils.sh && /post-provision.sh"

rm /mnt/utils.sh
rm /bootstrap.sh
rm /mnt/post-bootstrap.sh
rm /mnt/provision.sh
rm /mnt/post-provision.sh

umount -R /mnt

if [ $VM_ENV -eq 1 ]; then
	info "VM detected, not rebooting."
else
	reboot
fi
