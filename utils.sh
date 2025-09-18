#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Information logging function
info() { echo "[INF] $*"; } # { echo -e "[${GREEN}INF${NC}] $*"; }

# Warning logging function
warning() { echo "[WARN] $*"; } # { echo -e "[${YELLOW}WARN${NC}] $*"; }

# Error logging function
error() { echo "[ERR] $*"; } # { echo -e "[${RED}ERR${NC}] $*"; }

# Function to enable a systemd service if the package is installed
enable_if_present() {
    if yay -Qi "$1" &> /dev/null; then
        systemctl enable "$2"
    fi
}

# Function to run a command as the specified user
run_as_user() {
	su - "$USER" -c "$@"
}

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
    yay -S --noconfirm ${to_install[*]}
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