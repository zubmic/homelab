#!/bin/bash
# Install required software

distro=$(grep -e ^ID= /etc/*-release | tr -d "ID=")
packages="bridge-utils qemu qemu-kvm wget rsync"

case $distro in
    debian)
    packages="$packages libvirt-clients libvirt-daemon-system virtinst"
    apt update && apt install -y $packages
    ;;

    fedora)
    packages="$packages libvirt virt-install"
    dnf install -y $packages
    ;;
esac