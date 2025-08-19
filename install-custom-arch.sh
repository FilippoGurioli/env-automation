#!/usr/bin/env bash

########### Some useful functions ##############
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "[${GREEN}INF${NC}] $*"; }
warning() { echo -e "[${YELLOW}WARN${NC}] $*"; }
error() { echo -e "[${RED}ERR${NC}] $*"; }

########### Some useful functions ##############

set -euo pipefail # fail fast strategy

# Checking if the hostname is provided as first parameter
if [ $# -ne 2 ]; then
	error "provide the host name as first parameter (e.g. desktop/laptop/...) and the root password as second"
	exit 1
fi

# Setting an env var to spot if is vm
if grep -qEi 'qemu|vmware|virtualbox|kvm' /sys/class/dmi/id/sys_vendor 2>/dev/null; then
	VM_ENV=1
else
	VM_ENV=0
fi

info "ARCH CUSTOM INSTALL SCRIPT"

info "Updating system clock"
timedatectl set-ntp true

info "Selecting the fastest 10 mirrors"
sudo reflector --country "Italy,Germany,Switzerland,France" --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

info "Partitioning the disk"
if [ $VM_ENV -eq 1 ]; then
	SSD_DISK=$(lsblk -d -o NAME,TYPE | awk '$2=="disk" {print $1; exit}')
else
	SSD_DISK=$(lsblk -d -o NAME,ROTA,TYPE | awk '$3=="disk" && $2==0 {print $1; exit}')
fi
SSD_PATH="/dev/$SSD_DISK"

if [ -z "$SSD_DISK" ]; then
	error "No SSD detected. Aborting."
	exit 1
fi

OTHER_DISKS=($(lsblk -d -o NAME,ROTA | awk -v ssd="$SSD_DISK" '$1!=ssd && $1!="NAME" {print $1}'))

info "SSD: $SSD_PATH"
info "OTHERS: ${OTHER_DISKS[*]}"

info "Wiping the existing partitions in $SSD_PATH"
sgdisk --zap-all "$SSD_PATH" &>/dev/null
info "Creating EFI + ROOT partitions"
parted -s "$SSD_PATH" mklabel gpt #GUID Partition Table
parted -s "$SSD_PATH" mkpart EFI fat32 1MiB 513MiB #First partition, name:EFI, type:fat32, from 1MiB to 513 MiB (leaving first MiB blank)
parted -s "$SSD_PATH" set 1 esp on #Setting first partition as EFI System Partition (esp)
parted -s "$SSD_PATH" mkpart ROOT ext4 513MiB 100% #Second partition, name:ROOT, type:ext4, from 513MiB to 100% (end of disk) - the root file system

EFI_PART="${SSD_PATH}1"
ROOT_PART="${SSD_PATH}2"

info "Formatting partitions"
mkfs.fat -F32 "$EFI_PART" &>/dev/null
mkfs.ext4 -F "$ROOT_PART" &>/dev/null

info "Mounting EFI + ROOT"
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

info "Installing base functionalities"
pacstrap -K /mnt base linux-zen linux-firmware grub efibootmgr vim

info "Generating file systems table"
genfstab -U /mnt >> /mnt/etc/fstab

info "Mounting other disks"
if [ ${#OTHER_DISKS[@]} -eq 0 ]; then
	warning "No other disks found - skipping"
else
	for disk in "${OTHER_DISKS[@]}"; do
		DISK_PATH="/dev/$disk"
		PARTITIONS=$(lsblk -nrpo NAME "$DISK_PATH" | grep -v "$DISK_PATH")
		if [ -z "$PARTITIONS" ]; then
			echo "No partitions on $disk - skipping"
			continue
		fi

		for part in $PARTITIONS; do
			PART_NAME=$(basename "$part")
			MOUNT_DIR="/mnt/$PART_NAME"
			mkdir -p "$MOUNT_DIR"
			mount "$part" "$MOUNT_DIR" || warning "Failed to mount $part"
			info "Mounted $part"
		done
	done
fi

info "Changing root to /mnt"
cp ./chroot-commands.sh /mnt/
arch-chroot /mnt /bin/bash /chroot-commands.sh "$1" "$2"

info "MINIMAL INSTALLATION DONE"
info "Rebooting"
umount -R /mnt
reboot
exit 0
