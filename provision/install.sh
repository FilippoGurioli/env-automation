#!/bin/bash

set -euo pipefail # fail fast strategy

info "ARCH PROVISIONING SCRIPT"

info "Updating the system..."
pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
  info "Installing yay AUR helper..."
  pacman -S --needed git base-devel go --noconfirm
  
  info "Building yay as user..."
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  chown -R "$USER:$USER" /tmp/yay
  cd yay
  run_as_user "cd /tmp/yay && makepkg --noconfirm"
  
  info "Installing yay as root..."
  pacman -U /tmp/yay/yay-*.pkg.tar.* --noconfirm
  
  info "Cleaning up..."
  rm -rf /tmp/yay
else
  info "yay is already installed"
fi

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
	warning "No GPU detected, skipping gpu driver installation"
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

info "Installing audio packages ..."
install_packages "${AUDIO_DRIVERS[@]}"

info "Installing window manager and related packages..."
install_packages "${WINDOW_MANAGER[@]}"

info "Installing system utils..."
install_packages "${SYSTEM_UTILS[@]}"

info "Installing dev tools..."
install_packages "${DEV_TOOLS[@]}"

info "ARCH PROVISIONING DONE"
