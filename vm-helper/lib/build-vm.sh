#!/bin/bash

virsh net-define /usr/share/libvirt/networks/default.xml
virsh net-autostart default
virsh net-start default

virt-install \
	--name arch \
	--ram 2048 \
	--vcpus 4 \
	--disk path=/var/lib/libvirt/images/archlinux.qcow2,format=qcow2,size=20 \
	--cdrom /var/lib/libvirt/isos/archlinux-2025.08.01-x86_64.iso \
	--os-variant archlinux \
	--boot loader=/usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd,loader.readonly=yes,loader.type=pflash,nvram_template=/usr/share/edk2-ovmf/x64/OVMF_VARS.4m.fd \
	--machine q35 \
	--network network=default \
	--noautoconsole \
	--graphics vnc 
