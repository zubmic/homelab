from invoke import Collection, task

@task
def update(context, config):
    return context.run('apt update', hide=config['hide_output'])

@task
def install(context, config):
    tools = [
        'qemu', 
        'qemu-kvm', 
        'libvirt-clients', 
        'libvirt-daemon-system', 
        'bridge-utils',
        'virtinst',
        'wget'
    ]
    command = "apt install -y {}".format(' '.join(tools))
    return context.run(command, hide=config['hide_output'])

packages = Collection('packages')
packages.add_task(update)
packages.add_task(install)