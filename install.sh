#!/usr/bin/env bash
set -euo pipefail # fail fast strategy

echo "Checking connectivity"
if ! ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
	echo "No connection, aborting bootstrap install, re-launch this script once there is connectivity"
	return 1
else
	echo "Connected, starting bootstrap install"
fi

BASE_URL="https://raw.githubusercontent.com/FilippoGurioli/env-automation/dev"

curl -fsSL "$BASE_URL/bootstrap/install.sh" -o bootstrap.sh
curl -fsSL "$BASE_URL/bootstrap/chroot-commands.sh" -o chroot-commands.sh

chmod +x ./bootstrap.sh

./bootstrap.sh $@

curl -fsSL "$BASE_URL/provision/install.sh" -o /mnt/provision.sh

chmod +x /mnt/provision.sh

arch-chroot /mnt /bin/bash /provision.sh

rm /mnt/provision.sh

umount -R /mnt

reboot
