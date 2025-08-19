#!/usr/bin/env bash
set -euo pipefail # fail fast strategy

echo "Checking connectivity"
if ! ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
	echo "No connection, aborting custom install, re-launch this script once there is connectivity"
	return 1
else
	echo "Connected, starting custom install"
fi

BASE_URL="https://raw.githubusercontent.com/FilippoGurioli/env-automation/dev/bootstrap"

curl -fsSL "$BASE_URL/install.sh" -o bootstrap.sh
curl -fsSL "$BASE_URL/chroot-commands.sh" -o chroot-commands.sh

chmod +x ./bootstrap.sh

./bootstrap.sh $@
