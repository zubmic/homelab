"""
Set of tasks managing the state of virtual machine
"""
import sys
import libvirt
from invoke import Collection, task
from helpers import filename_from_url

namespace = Collection()

@task
def install(context):
    """
    Installs a virtual machine in unattended way with preconfigured properties.
    """
    disk_path = context['libvirt']['dir'] + context['config']['hostname'] + '.qcow2'
    iso_path = context['libvirt'].dir + filename_from_url(context['iso_url']) + '.iso'
    config_name = filename_from_url(context['iso_url']) + '.ks'
    config_path = context['libvirt'].dir + config_name

    install_command = f"""sudo virt-install \
        --accelerate \
        --check-cpu \
        --connect=qemu:///system \
        --disk {disk_path},size={context['libvirt']['vm']['disk_size']},format=qcow2 \
        --extra-args="inst.ks=file:/{config_name}" \
        --hvm \
        --initrd-inject={config_path} \
        --location={iso_path} \
        --name {context['config']['hostname']} \
        --network={context['libvirt']['vm']['network']} \
        --noreboot \
        --os-variant={context['libvirt']['vm']['os_variant']} \
        --ram {context['libvirt']['vm']['ram']} \
        --vcpus={context['libvirt']['vm'].vcpus} \
        --wait -1
    """
    return context.run(install_command)

namespace.add_task(install)
