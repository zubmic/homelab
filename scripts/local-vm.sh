#!/bin/bash
## local-vm.sh: install, reinstall or destroy a VM
## Example use: ./local-vm.sh -k rockylinux.ks -m reinstall -n homelab -s 20 -u https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.5-x86_64-minimal.iso

# Assign the named parameters to variables with meaningful names
while getopts k:m:n:u:s: flag
do
    case "${flag}" in
        k) kickstart=${OPTARG};;
        m) mode=${OPTARG:=install};;
        n) name=${OPTARG:=virtual-machine};;
        u) url=${OPTARG};;
        s) size=${OPTARG:=20};;
    esac
done

# Exit if required parameters are missing
if [ -z $kickstart ] || [ -z $url ]
then
    printf "Error! Required parameters are missing! Given values are:\nkickstart=$kickstart\nurl=$url\n"
    exit 1
fi

disk_name="$name-disk.qcow2"
packages="qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst puppet-bolt"
iso_dir="/var/lib/libvirt/images"

# Get the filename from url path
iso_file=$(printf -- "%s" "${url##*/}")

# Download the iso if not present already
wget -q --show-progress -nc -O $iso_dir/$iso_file $url

# Install missing packages
echo "### INSTALLING PACKAGES ###"
apt install -qq -y $packages

# Copy kickstart to libvirt directory
cp ../files/$kickstart $iso_dir/

# Fix permissions
chown -R libvirt-qemu:libvirt-qemu $iso_dir

# Purge VM in case of reinstall or cleanup
if [ $mode == "reinstall" ] || [ $mode == "destroy" ]
then
    virsh --log virsh.log "destroy $name;undefine $name;vol-delete --pool default $disk_name" &>/dev/null
fi

# Install a VM in an automated way
if [ $mode == "install" ] || [ $mode == "reinstall" ]
then
    echo -n "### INSTALLING VM ###"
    virt-install --accelerate \
        --check-cpu \
        --connect=qemu:///system \
        --disk $iso_dir/$disk_name,size=$size,format=qcow2 \
        --extra-args="inst.ks=file:/$kickstart" \
        --hvm \
        --initrd-inject=$iso_dir/$kickstart \
        --location=$iso_dir/$iso_file \
        --name $name \
        --network=default \
        --noautoconsole \
        --nographics \
        --noreboot \
        --os-variant=generic \
        --ram 2048 \
        --vcpus=2 \
        --wait -1
fi