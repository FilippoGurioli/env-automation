#!/bin/bash

virsh destroy arch 2>/dev/null
virsh undefine --remove-all-storage arch --nvram
virsh net-destroy default
virsh net-undefine default
