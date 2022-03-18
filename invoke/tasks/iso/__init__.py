from invoke import Collection, task
from jinja2 import Template
from os.path import exists

@task
def get(context, config):
    # Create path for the iso to be saved as
    iso_path = config['files-dir'] + config['template']['name'] + '.iso'
    # Prepare wget command with its arguments
    command = "wget -O {} {}".format(iso_path, config['url'])
    # Download the iso from url
    if exists(iso_path) != True:
        result = context.run(command, hide=config['hide_output'])

@task
def prepare(context, config):
    # Define file names
    template_path = config['files-dir'] + config['template']['name'] + '.jinja2'
    output_path = config['files-dir'] + config['template']['name'] + config['template']['output-ext']
    iso_path = config['files-dir'] + config['template']['name'] + '.iso'

    # Render the template
    with open(template_path) as file:
        # Read the template and substitute variables with values
        output = Template(file.read()).stream(config['template']['variables'])
        # Save the result as a file
        output.dump(output_path)


    # Copy the iso and config file to libvirt owned directory
    context.run('cp {} {}'.format(iso_path, config['libvirt-images-dir']))
    context.run('cp {} {}'.format(output_path, config['libvirt-images-dir']))

    # Change ownership of the image and configuration file for automated install
    context.run('chown -R {0}:{0} {1}'.format(config['iso-owner'], config['libvirt-images-dir']))

iso = Collection('iso')
iso.add_task(get)
iso.add_task(prepare)