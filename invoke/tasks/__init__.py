from invoke import Collection, task, executor
# import tasks as local modules
from . import packages, iso, vm

namespace = Collection()
namespace.add_collection(packages)
namespace.add_collection(iso)
namespace.add_collection(vm)

@task
def install(c):
    # Execute config.load task to load the configure
    config = executor.Executor(namespace).execute('config.load')
    # Unwrap the actual config from the result dict
    config = list(config.values())[0]
    # Install required software packages
    executor.Executor(namespace).execute(('packages.update', {'config': config}))
    executor.Executor(namespace).execute(('packages.install', {'config': config}))
    # Download iso and prepare config for installation
    executor.Executor(namespace).execute(('iso.get', {'config': config}))
    executor.Executor(namespace).execute(('iso.prepare', {'config': config}))
    # Install the virtual machine
    executor.Executor(namespace).execute(('vm.install', {'config': config}))

namespace.add_task(install)