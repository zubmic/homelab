#!/bin/bash

# Configure variables and functions
source "$(dirname "$0")/config.sh"

# Prompt for sudo password if needed
escalate_privileges

# Download the ISO only if it's not present already
if [ ! -f $iso_path ]; then
    colorful_message green "Downloading iso"
    wget -nc $iso_url -O $iso_path
else
    colorful_message green "The iso already present - skipping download"
fi

# Check if default network is started
virsh_default_network=$(virsh net-list --all | grep default)

if [[ "$virsh_default_network" == *"no"* ]]; then
    colorful_message yellow "Network not configured for autostart - autostarting"
    virsh net-autostart default
fi

if [[ "$virsh_default_network" == *"inactive"* ]]; then
    colorful_message yellow "Network not active - activating"
    virsh net-start default
fi

# Install VM if the domain doesn't already exist
domain=$(virsh list --all | grep -o $gvm_name)

if [ -z "$domain" ]; then
    colorful_message yellow "Domain $gvm_name not installed - installing"
    cp "$(dirname "$0")/files/$gvm_name.ks" $gvm_config

    virt-install \
        --accelerate \
        --check-cpu \
        --connect=qemu:///system \
        --disk $gvm_disk,size=20,format=qcow2 \
        --extra-args="inst.ks=file:/$gvm_name.ks" \
        --hvm \
        --initrd-inject=$gvm_config \
        --location=$iso_path \
        --name $gvm_name \
        --network=default \
        --noreboot \
        --os-variant=generic \
        --ram $gvm_ram \
        --vcpus=$gvm_vcpus \
        --wait -1

    # Enable qemu-guest-agent
    colorful_message green "Enabling qemu-guest-agent"
    virsh attach-device $gvm_name --file $(dirname $0)/files/guest-agent.xml --config

    # Start the VM
    colorful_message green "Starting $gvm_name - please wait"
    virsh start $gvm_name && sleep 30
else
    colorful_message green "Domain $domain already installed - starting vm - please wait"
    virsh start $gvm_name && sleep 30
fi

# Get the guest IP address
gvm_ip=$(virsh domifaddr $gvm_name | awk 'FNR == 3 { sub("/.*", ""); print $4 }')
echo "The guest address is: $gvm_ip"

# Prepare qemu-guest-agent according to this: https://access.redhat.com/solutions/732773
# setenforce 0 before adding the ssh key

# Configure ssh access
#colorful_message green "Setting up the ssh key"
virsh set-user-sshkeys $gvm_name --user $gvm_username --file /home/$gvm_username/.ssh/$gvm_ssh_key

# Run Ansible playbook to configure the rest
# export ANSIBLE_HOST_KEY_CHECKING=False
# ansible-playbook "$(dirname $0)/../ansible/homelab.yml" -i $gvm_ip, -k