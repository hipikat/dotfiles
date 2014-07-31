
from glob import glob
from itertools import chain
from os import path

#from fabric.api import env, run, sudo, prefix
from fabric.api import run
from fabric.operations import put

from pprint import pprint



def _exclude_substrings(string_list):
    """
    Takes a list of strings and returns a list in which any strings that
    are substrings of longer strings, matching from the start, are excluded.
    """
    leftovers = []

    def _longer_exists(a_string, set_of_strings):
        for other_string in set_of_strings:
            if other_string.startswith(a_string) and len(a_string) < len(other_string):
                return True
        return False

    for a_string in string_list:
        if not _longer_exists(a_string, string_list):
            leftovers.append(a_string)

    return leftovers


#def setup_home(*args, **kwargs):
#    """
#    Try to clone a git repository of 'dotfiles' to a remote host.
#    """


def migrate_home(*args, **kwargs):
    """
    Copy 'home' files to the remote host, e.g. IRC logs.
    """
    with open('.home_files') as home_files_file:
        home_file_globs = [line.strip() for line in home_files_file.readlines()]

    home_files = tuple(chain.from_iterable(glob(pattern) for pattern in home_file_globs))

    # TODO: Tar and gzip files, send them to the remote host and unpack...
    #for home_file in home_files:



def send_private(*args, **kwargs):
    """
    Copy files listed (by glob pattern) in ~/.private_files to a remote host.
    """
    with open('.private_files') as private_files_file:
        private_file_globs = [line.strip() for line in private_files_file.readlines()]

    private_files = tuple(chain.from_iterable(glob(pattern) for pattern in private_file_globs))

    # Create the deepest paths that have to exist on the remote
    def longer_exists(a_path, set_of_paths):
        for other_path in set_of_paths:
            if other_path.startswith(a_path) and len(a_path) < len(other_path):
                return True
        return False

    remote_dirs = []
    all_remote_dirs = set(map(path.dirname, private_files))
    for remote_dir in all_remote_dirs:
        if remote_dir and not longer_exists(remote_dir, all_remote_dirs):
            remote_dirs.append(remote_dir)

    remote_dirs = _exclude_substrings(set(map(path.dirname, private_files)))

    for remote_dir in remote_dirs:
        run('mkdir -p ' + remote_dir)

    # Copy private files across
    for private_file in private_files:
        put(private_file, private_file)
