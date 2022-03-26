from invoke import Collection, task, Result
from os.path import exists, basename
from re import split

namespace = Collection()

@task
def get(context):
    url = context['iso_url']
    # Extract file name from url
    file_name = basename(url)

    # Split the string to drop version and architecture
    file_name = split('\.|-', file_name)

    # Combine the name with prefix
    file_name = file_name[0].lower() + '.' + file_name[-1]
    file_path = context['file_dir'] + file_name

    # Download the file if it does not exist and return the result
    if not exists(file_path):
        return context.run(f"wget {url} -O {file_path}")
    else:
        return Result(f"File {file_path} already exists. Nothing to do.")

@task
def copy(context):
    # Copy the files to the libvirt directory in order to prevent permission issues
    context.run(f"sudo rsync -rog --chown={context['libvirt_user']}:{context['libvirt_user']} {context['file_dir']} {context['libvirt_dir']}")

namespace.add_task(get)
namespace.add_task(copy)