#!/bin/bash

# Clear screen
clear

# Exit on any error
set -e

# Source utility functions
source utils.sh

# Source the package list
source_if_present "packages.conf"

# Update the system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
if ! command -v yay &> /dev/null; then
  echo "Installing yay AUR helper..."
  sudo pacman -S --needed git base-devel --noconfirm
  if [[ ! -d "yay" ]]; then
    echo "Cloning yay repository..."
  else
    echo "yay directory already exists, removing it..."
    rm -rf yay
  fi

  git clone https://aur.archlinux.org/yay.git

  cd yay
  echo "building yay..."
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay is already installed"
fi

# Install packages by category
# echo "Installing system utilities..."
# install_packages "${SYSTEM_UTILS[@]}"
  
# echo "Installing development tools..."
# install_packages "${DEV_TOOLS[@]}"
  
# echo "Installing desktop environment..."
# install_packages "${DESKTOP[@]}"
  
# echo "Installing media packages..."
# install_packages "${MEDIA[@]}"
  
# echo "Installing fonts..."
# install_packages "${FONTS[@]}"
  
# # Enable services
# echo "Configuring services..."
# for service in "${SERVICES[@]}"; do
#   if ! systemctl is-enabled "$service" &> /dev/null; then
#     echo "Enabling $service..."
#     sudo systemctl enable "$service"
#   else
#     echo "$service is already enabled"
#   fi
# done
  
# echo "Installing flatpaks (like discord and spotify)"
# . install-flatpaks.sh

echo "Setup complete! You may want to reboot your system."