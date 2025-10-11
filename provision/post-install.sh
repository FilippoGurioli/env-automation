#!/bin/bash

info "POST PROVISION SCRIPT"

info "Selecting the fastest 10 mirrors..."
reflector --country "Italy,Germany,Switzerland,France" --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

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
enable_if_present "tlp" "tlp"
enable_if_present "upower" "upower"
enable_if_present "bluez" "bluetooth"

info "POST PROVISION DONE"

return 0