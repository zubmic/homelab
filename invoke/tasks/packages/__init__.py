from invoke import Collection, task

namespace = Collection()

@task
def install(context):
    # Convert yaml list to string
    packages_list = ' '.join(context['packages'])
    return context.run(f"sudo apt update && sudo apt install -y {packages_list}")

namespace.add_task(install)