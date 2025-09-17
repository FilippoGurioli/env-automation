#!/bin/bash

echo "POST INSTALL SCRIPT"

info "Installing oh-my-zsh..."
run_as_user 'export RUNZSH=no CHSH=no && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

info "Installing Powerlevel 10k..."
yay powerlevel10k --noconfirm


info "Selecting the fastest 10 mirrors..."
sudo reflector --country "Italy,Germany,Switzerland,France" --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

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
