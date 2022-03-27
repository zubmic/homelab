"""
Set of helpers function that might be used within the tasks
"""
from os.path import basename
from re import split

def filename_from_url(url):
    """
    Extracts the filename from an url.
    The version and architecture are dropped for better readability.
    """
    filename = basename(url)
    filename = split(r'\.|-', filename)
    filename = filename[0].lower()

    return filename
