"""
Set of tasks responsible for handling jinja2 templates
"""
from invoke import Collection, task
from jinja2 import Template
from helpers import filename_from_url

namespace = Collection()

@task
def prepare(context):
    """
    Prepares the configuration file based on a template and variables.
    """
    template_name = filename_from_url(context['iso_url']) + '.jinja2'
    config_name = filename_from_url(context['iso_url']) + '.ks'

    with open(context['file_dir'] + template_name, encodig='utf-8', mode='r') as file:
        config = Template(file.read()).stream(context['config'])
        config.dump(context['file_dir'] + config_name)
