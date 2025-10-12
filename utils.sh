#!/usr/bin/env bash

if [[ -v BUFF_LOG ]]; then
  RED=''
  GREEN=''
  YELLOW=''
  NC=''
else
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
fi

# Information logging function
info() { echo -e "[${GREEN}INF${NC}] $*"; }

# Warning logging function
warning() { echo -e "[${YELLOW}WARN${NC}] $*"; }

# Error logging function
error() { echo -e "[${RED}ERR${NC}] $*"; }

# Function to enable a systemd service if the package is installed
enable_if_present() {
    if yay -Qi "$1" &> /dev/null; then
        systemctl enable "$2"
    fi
}

# Function to run a command as the specified user
run_as_user() {
  # Ensure USER is set
  if [[ -z "${USER:-}" ]]; then
    error "run_as_user: USER is not set"
    return 1
  fi

  # Prefer runuser (doesn't require a TTY). Fall back to su if unavailable.
  if command -v runuser &>/dev/null; then
    # Use a login shell and allow shell expansions; run command via bash -lc
    runuser -u "$USER" -- /bin/bash -lc "$@"
  else
    su - "$USER" -c "$@"
  fi
}

# Functions to check if a package is installed
is_installed() {
  if command -v pacman &>/dev/null; then
    pacman -Qi "$1" &> /dev/null
  else
    return 1
  fi
}
is_group_installed() {
  if command -v pacman &>/dev/null; then
    pacman -Qg "$1" &> /dev/null
  else
    return 1
  fi
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
    info "Installing: ${to_install[*]}"
    run_as_user "yay -S --noconfirm ${to_install[*]}"
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