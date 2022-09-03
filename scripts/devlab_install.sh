#!/bin/bash

url='https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-x86_64-minimal.iso'
guest_vm_name='devlab'
libvirt_path='/var/lib/libvirt/images'
iso_path="$libvirt_path/rocky.iso"
disk_path="$libvirt_path/$guest_vm_name.qcow2"
config_path="$libvirt_path/$guest_vm_name.ks"

domain=$(virsh list --all | grep $guest_vm_name)

username='zubmic'

# Download the ISO only if it's not present already
if [ ! -f $iso_path ]; then
    wget $url -O $iso_path
fi

# Install VM if the domain doesn't already exist
if [ -z "$domain" ]; then
    cp ../files/"$guest_vm_name.ks" $config_path

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