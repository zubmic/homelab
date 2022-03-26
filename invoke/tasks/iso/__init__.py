"""
Set of tasks related to iso file
"""
from os.path import exists
from invoke import Collection, task, Result
import helpers

namespace = Collection()

@task
def get(context):
    """
    Downloads a file from url if not already present.
    """
    file_path = context['file_dir'] + helpers.iso_name_from_url(context['iso_url'])

    if not exists(file_path):
        return context.run(f"wget {context['iso_url']} -O {file_path}")

    return Result(f"File {file_path} already exists. Nothing to do.")

@task
def copy(context):
    """
    Copies the files to libvirt directory via rsync.
    It allows to avoid issues with permissions later on.
    """
    rsync_args = f"--chown={context['libvirt_user']} {context['file_dir']} {context['libvirt_dir']}"
    return context.run("sudo rsync -rog " + rsync_args)

namespace.add_task(get)
namespace.add_task(copy)
