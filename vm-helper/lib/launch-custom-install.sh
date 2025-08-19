#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Waiting for a minute to wait arch to boot..."
sleep 60

until virsh qemu-agent-command arch '{"execute":"guest-ping"}' &>/dev/null; do
	echo "Waiting for guest agent..."
	sleep 2
done

echo "Guest agent is ready!"

echo "Launching install.sh"
"$SCRIPT_DIR/arch-exec.sh" "curl -fsSL https://raw.githubusercontent.com/FilippoGurioli/dotfiles/master/env-automation/install.sh | bash -s -- $1 $2"
