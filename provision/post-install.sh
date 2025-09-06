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

run_as_user() {
	su - "$USER" -c "$@"
}

########### Some useful functions ##############

USER=$2

echo "POST INSTALL SCRIPT"
info "Setting sudo insults..."
# Check if the line exists (commented or not), if not add it
grep -q "^[[:space:]]*#*[[:space:]]*Defaults[[:space:]]\+insults" /etc/sudoers || echo "Defaults insults" >> /etc/sudoers

# Then ensure it's uncommented
sed -i 's/^[[:space:]]*#[[:space:]]*\(Defaults[[:space:]]\+insults\)/\1/' /etc/sudoers

info "Adding user to necessary groups..."
usermod -aG docker $USER
usermod -aG video $USER
usermod -aG audio $USER
usermod -aG input $USER

info "Enabling services..."
systemctl enable NetworkManager
systemctl enable sshd
run_as_user "systemctl enable --user pipewire pipewire-pulse wireplumber"

enable_if_present "tlp" "tlp"
enable_if_present "upower" "upower"
enable_if_present "bluez" "bluetooth"

info "Setting zsh as default shell for $USER"
chsh -s $(which zsh) $USER

echo "POST INSTALL DONE"
