set -euo pipefail # fail fast strategy

info "POST INSTALL SCRIPT"

info "Setting time zone..."
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

info "Setting localization..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_ADDRESS=it_IT.UTF-8" >> /etc/locale.conf
echo "LC_IDENTIFICATION=it_IT.UTF-8" >> /etc/locale.conf
echo "LC_MEASUREMENT=it_IT.UTF-8" >> /etc/locale.conf
echo "LC_MONETARY=it_IT.UTF-8" >> /etc/locale.conf
echo "LC_NAME=it_IT.UTF-8" >> /etc/locale.conf
echo "LC_NUMERIC=it_IT.UTF-8" >> /etc/locale.conf
echo "LC_PAPER=it_IT.UTF-8" >> /etc/locale.conf
echo "LC_TELEPHONE=it_IT.UTF-8" >> /etc/locale.conf
echo "LC_TIME=it_IT.UTF-8" >> /etc/locale.conf

HOSTNAME="arch-$1"

info "Setting hostname to $HOSTNAME..."
echo "$HOSTNAME" > /etc/hostname

info "Setting hosts..."
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

info "Setting the root password to $PASSWORD..."
echo "root:$PASSWORD" | chpasswd

info "Creating user '$USER' with password '$PASSWORD'..."
useradd -m -G wheel -s /bin/bash "$USER"
echo "$USER:$PASSWORD" | chpasswd

info "Enabling sudo for wheel group..."
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

info "Installing bootloader..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

info "POST INSTALL SCRIPT COMPLETE"