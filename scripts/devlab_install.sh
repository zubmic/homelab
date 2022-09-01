#!/bin/bash

url='https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-x86_64-minimal.iso'
name='devlab'
libvirt_path='/var/lib/libvirt/images'
iso_path="$libvirt_path/rocky.iso"
disk_path="$libvirt_path/$name.qcow2"
config_path="$libvirt_path/$name.ks"

domain=$(virsh list --all | grep $name)

# Download the ISO only if it's not present already
if [ ! -f $iso_path ]; then
    wget $url -O $iso_path
fi

# Install VM if the domain doesn't already exist
if [ -z "$domain" ]; then
    cp ../files/"$name.ks" $config_path

    virt-install \
        --accelerate \
        --check-cpu \
        --connect=qemu:///system \
        --disk $disk_path,size=20,format=qcow2 \
        --extra-args="inst.ks=file:/$name.ks" \
        --hvm \
        --initrd-inject=$config_path \
        --location=$iso_path \
        --name $name \
        --network=default \
        --noreboot \
        --os-variant=generic \
        --ram 4096 \
        --vcpus=2 \
        --wait -1

    # Start the VM
    virsh start $name && sleep 5

    # Get the IP address
    address=$(virsh domifaddr devlab | awk 'FNR == 3 { sub("/.*", ""); print $4 }')

    echo "The address is: $address"
fi