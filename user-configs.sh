#!/bin/bash

info "$USER USER CONFIGS SCRIPT"

info "Installing oh-my-zsh..."
export RUNZSH=no CHSH=no && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

info "Installing Powerlevel 10k..."
yay powerlevel10k --noconfirm

info "Enabling user services..."
systemctl enable --user pipewire pipewire-pulse wireplumber

info "Setting zsh as default shell"
chsh -s $(which zsh)

info "$USER USER CONFIGS DONE"

return 0