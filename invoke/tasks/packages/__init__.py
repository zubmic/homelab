"""
Set of tasks related to managing packages
"""
from invoke import Collection, task

namespace = Collection()

@task
def install(context):
    """
    Installs a list of packages defined in the config file
    """
    packages_list = ' '.join(context['packages'])
    return context.run(f"sudo apt update && sudo apt install -y {packages_list}")

namespace.add_task(install)
