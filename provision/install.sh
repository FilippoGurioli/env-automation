#!/bin/bash

########### Some useful functions ##############
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "[${GREEN}INF${NC}] $*"; }
warning() { echo -e "[${YELLOW}WARN${NC}] $*"; }
error() { echo -e "[${RED}ERR${NC}] $*"; }

# Functions to check if a package is installed
is_installed() {
  pacman -Qi "$1" &> /dev/null
}

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

# Function to detect if the computer is a laptop
is_laptop() {
	if [[ -r /sys/class/dmi/id/chassis_type ]]; then
		case "$(cat /sys/class/dmi/id/chassis_type)" in
			8|9|10|14) return 0 ;;
			*) return 1;;
		esac
	fi
	return 1
}

########### Some useful functions ##############

set -euo pipefail # fail fast strategy

USER="$2"

info "ARCH PROVISIONING SCRIPT"

info "Updating the system"
pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
  info "Installing yay AUR helper..."
  pacman -S --needed git base-devel --noconfirm
  su - "$USER" -c '
      cd /tmp
      git clone https://aur.archlinux.org/yay.git
      cd yay
      makepkg -si --noconfirm
      cd ..
      rm -rf yay
  '
else
  info "yay is already installed"
fi

BASE_URL="https://raw.githubusercontent.com/FilippoGurioli/env-automation/dev/provision"

curl -fsSL "$BASE_URL/packages.conf" -o /packages.conf
source /packages.conf

info "Installing essential packages ..."
install_packages "${ESSENTIALS[@]}"

info "Installing drivers..."
if rfkill list | grep -qi bluetooth || lsusb | grep -qi bluetooth || lspci | grep -qi bluetooth; then
	info "Installing bluetooth drivers..."
	install_packages "${BT_DRIVERS[@]}"
else
	info "No bluetooth hardware detected, skipping bt drivers installation"
fi

if ls /dev/video* &>/dev/null; then
	info "Installing webcam drivers..."
	install_packages "${WEBCAM_DRIVERS[@]}"
else
	info "No webcam hardware detected, skipping webcam drivers installation"
fi

GPU=$(lspci -nnk | grep -E "VGA|3D|Display" || true)

if [[ -z "$GPU" ]]; then
	info "No GPU detected, skipping gpu driver installation"
else
	info "GPU detected: $GPU"
	if echo "$GPU" | grep -qi "Intel"; then
		info "Installing Intel drivers..."
		install_packages "${INTEL_GPU_DRIVERS[@]}"
	elif echo "$GPU" | grep -qi "AMD|ATI"; then
		info "Installing AMD drivers..."
		install_packages "${AMD_GPU_DRIVERS[@]}"
	elif echo "$GPU" | grep -qi "NVIDIA"; then
		info "Installing NVIDIA drivers..."
		install_packages "${NVIDIA_GPU_DRIVERS[@]}"
	else
		info "Unknown GPU vendor. Not installing any drivers"
	fi
fi

if is_laptop; then
	echo "Detected a laptop computer, installing laptop specific packages..."
	install_packages "${LAPTOP[@]}"
fi

info "ARCH PROVISIONING DONE"

curl -fsSL "$BASE_URL/post-install.sh" -o /post-install.sh
chmod +x /post-install.sh

/post-install.sh

rm /etc/sudoers.d/temp-pacman