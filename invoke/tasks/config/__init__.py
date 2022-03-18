import json
from invoke import task

@task
def load(c, config_file='../config.json'):
    # Load in JSON as dict
    with open(config_file, 'r') as file:
        return json.load(file)