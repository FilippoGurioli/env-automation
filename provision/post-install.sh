#!/bin/bash

########### Some useful functions ##############
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "[${GREEN}INF${NC}] $*"; }
warning() { echo -e "[${YELLOW}WARN${NC}] $*"; }
error() { echo -e "[${RED}ERR${NC}] $*"; }

enable_if_present() {
    if yay -Qi "$1" &> /dev/null; then
        systemctl enable "$2"
    fi
}

########### Some useful functions ##############

echo "POST INSTALL SCRIPT"

info "Adding user to necessary groups..."
usermod -aG wheel $1
usermod -aG docker $1
usermod -aG video $1
usermod -aG audio $1
usermod -aG input $1

if ! grep -q '^%wheel ALL=(ALL:ALL) ALL' /etc/sudoers; then
    info "Enabling wheel group in sudoers (password required)..."
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

info "Enabling services..."
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable --user pipewire pipewire-pulse wireplumber

enable_if_present "tlp" "tlp"
enable_if_present "upower" "upower"
enable_if_present "bluez" "bluetooth"

info "Setting zsh as default shell for $USER"
chsh -s $(which zsh) $USER

echo "POST INSTALL DONE"
