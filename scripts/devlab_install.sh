#!/bin/bash

# Configure variables
source "$(dirname "$0")/config.sh"

# Download the ISO only if it's not present already
if [ ! -f $iso_path ]; then
    wget $url -O $iso_path
fi

# Install VM if the domain doesn't already exist
if [ -z "$domain" ]; then
    cp "$(dirname "$0")/files/$guest_vm_name.ks" $config_path

    virt-install \
        --accelerate \
        --check-cpu \
        --connect=qemu:///system \
        --disk $disk_path,size=20,format=qcow2 \
        --extra-args="inst.ks=file:/$guest_vm_name.ks" \
        --hvm \
        --initrd-inject=$config_path \
        --location=$iso_path \
        --name $guest_vm_name \
        --network=default \
        --noreboot \
        --os-variant=generic \
        --ram 4096 \
        --vcpus=2 \
        --wait -1

    # Start the VM
    virsh start $guest_vm_name && sleep 5

    # Get the guest IP address
    guest_ip=$(virsh domifaddr devlab | awk 'FNR == 3 { sub("/.*", ""); print $4 }')
    echo "The guest address is: $guest_ip"
fi