from invoke import Collection, task

@task
def install(context, config):
    # Define the path to the vm disk file
    disk_file = '/var/lib/libvirt/images/' + config['template']['variables']['hostname'] + '.' + config['vm-properties']['format']

    # Define location of the iso to be used
    location = config['libvirt-images-dir'] + config['template']['name'] + '.iso'

    # Prepare kickstart injection parameters
    if config['template']['output-ext'] == '.ks':
        kickstart_name = config['template']['name'] + config['template']['output-ext']
        extra_args = "inst.ks=file:/{}".format(kickstart_name)
        initrd_inject = config['libvirt-images-dir'] + kickstart_name

    install_command = "virt-install --accelerate --check-cpu --connect=qemu:///system --disk {},size={},format={} --extra-args=\"{}\" --hvm --initrd-inject={} --location={} --name {} --network={} --noreboot --os-variant={} --ram {} --vcpus={} --wait -1".format(
            disk_file, 
            config['vm-properties']['disk-size'],
            config['vm-properties']['format'],
            extra_args,
            initrd_inject,
            location,
            config['template']['variables']['hostname'],
            config['vm-properties']['network'],
            config['vm-properties']['os-variant'],
            config['vm-properties']['ram'],
            config['vm-properties']['vcpus']
    )
    context.run(install_command)

vm = Collection('vm')
vm.add_task(install)