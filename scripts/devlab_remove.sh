#!/bin/bash

# Configure variables
source "$(dirname "$0")/config.sh"

# Gracefully stop and remove the VM together with associated storage
if [ ! -z "$domain" ]; then
    virsh destroy --domain $guest_vm_name --graceful
    virsh undefine $guest_vm_name --remove-all-storage
fi

# Delete iso if specified
if [[ "$@" == *"--remove-iso"* ]] && [[ -f $iso_path ]]; then
    rm -v $iso_path
fi

# Delete kickstart if specified
if [[ "$@" == *"--remove-kickstart"* ]] && [[ -f $config_path ]]; then
    rm -v $config_path
fi