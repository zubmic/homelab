#!/bin/bash

### VARIABLES ###

# ISO variables
iso_url='https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-x86_64-minimal.iso'
#iso_url='https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.0-20220805.0-x86_64-minimal.iso'
iso_path='/tmp/rockylinux.iso'

# VM configuration variables
gvm_name='devlab'
gvm_disk="/var/lib/libvirt/images/$gvm_name.qcow2"
gvm_config="/tmp/$gvm_name.ks"
gvm_ram=4096
gvm_vcpus=2

# Access variables
gvm_username='zubmic'
gvm_ssh_key='id_rsa_local_vm.pub'

### FUNCTIONS ###

# Prints colorful message to enhance the logging
colorful_message () {
    text="### $2 ###"
    case $1 in
    yellow)
        echo -e "\e[1;33m$text\e[0m"
    ;;
    green)
        echo -e "\e[1;32m$text\e[0m"
    ;;
    esac
}

# Prompts for sudo password if needed to escalate privileges
escalate_privileges () {
    if [ $(id -u) != 0 ]; then
        colorful_message yellow "This script requires root permissions!"
        sudo "$0" "$@"
        exit
    fi
}
