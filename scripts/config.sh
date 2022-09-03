#!/bin/bash

url='https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-x86_64-minimal.iso'
guest_vm_name='devlab'
libvirt_path='/var/lib/libvirt/images'
iso_path="$libvirt_path/rocky.iso"
disk_path="$libvirt_path/$guest_vm_name.qcow2"
config_path="$libvirt_path/$guest_vm_name.ks"
domain=$(virsh list --all | grep $guest_vm_name)
username='zubmic'