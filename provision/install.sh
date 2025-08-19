#!/bin/bash

########### Some useful functions ##############
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "[${GREEN}INF${NC}] $*"; }
warning() { echo -e "[${YELLOW}WARN${NC}] $*"; }
error() { echo -e "[${RED}ERR${NC}] $*"; }

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &> /dev/null
}

# Function to check if a package is installed
is_group_installed() {
  pacman -Qg "$1" &> /dev/null
}

# Function to install packages if not already installed
install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing: ${to_install[*]}"
    yay -S --noconfirm "${to_install[@]}"
  fi
} 

########### Some useful functions ##############

set -euo pipefail # fail fast strategy

info "ARCH PROVISIONING SCRIPT"

info "Updating the system"
pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
  info "Installing yay AUR helper..."
  pacman -S --needed git base-devel --noconfirm
  if [[ ! -d "yay" ]]; then
    info "Cloning yay repository..."
  else
    info "yay directory already exists, removing it..."
    rm -rf yay
  fi

  git clone https://aur.archlinux.org/yay.git

  cd yay
  info "building yay..."
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  info "yay is already installed"
fi

BASE_URL="https://raw.githubusercontent.com/FilippoGurioli/env-automation/dev/provision"

curl -fsSL "$BASE_URL/packages.conf" -o /packages.conf
source /packages.conf

info "Installing essential packages ..."
install_packages "${ESSENTIALS[@]}"

info "ARCH PROVISIONING DONE"

curl -fsSL "$BASE_URL/post-install.sh" -o /post-install.sh
chmod +x /post-install.sh

/post-install.sh
