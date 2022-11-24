#!/bin/bash
# Prepare the host system for VM installation

distro=$(grep -e ^ID= /etc/*-release | tr -d "ID=")
packages="ansible bridge-utils qemu qemu-kvm wget"

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