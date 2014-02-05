#!/usr/bin/env python
# coding=utf-8
"""
Create symlinks to files and directories in the current directory, at a
specified destination.  Where directories are copied (as specified by a
configuration file), linking happens recursively. The 'configuration
file' is just a file named link_files.json in the current directory with
a dict potentially containing pattern lists under the keys 'ignore' and
'copy'.
"""

# Copyright © 2014, Adam Wright <adam@hipikat.org>
# All rights reserved.
#
# The BSD 6-Clause License
# ========================
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import argparse
import os
from os.path import join, isdir
from fnmatch import fnmatch
from itertools import chain
import json
import sys

from pprint import pprint


arg_parser = argparse.ArgumentParser(description=__doc__)
dest_group = arg_parser.add_mutually_exclusive_group(required=True)
dest_group.add_argument('-d', '--dir', type=str,
                        help="Install files into DIR.")
dest_group.add_argument('-u', '--user', type=str,
                        help="Install files into USER's home directory.")
dest_group.add_argument('-c', '--current-user', default=False, action='store_true',
                        help="Install files into the current user's home directory.")
arg_parser.add_argument('-f', '--force', default=False, action='store_true',
                        help="Overwrite existing files and links.")


def get_config(source_dir):
    """
    Return a dictionary with a list of `ignore_patterns` and `copy_patterns`,
    which are full paths to match (just `startswith`) against file paths.
    """
    try:
        with open('link_files.json') as fp:
            config = json.load(fp)
    except IOError as ex:
        if ex.errno == 2:     # File not found
            config = {}
        else:
            raise
    return {
        'copy_patterns': [join(source_dir, pat) for pat in config.get('copy', [])],
        'ignore_patterns': [join(source_dir, pat) for pat in config.get('ignore', [])] +
        [os.path.abspath(__file__),
         join(os.path.abspath(os.path.dirname(__file__)), 'link_files.json')],
    }


def main(*argv, **kwargs):
    opts = arg_parser.parse_args()

    # Options dir, user and current_user are a mutually exclusive (but required)
    # group, so one of those attributes on opts will be not None.
    if opts.dir:
        dest_dir = opts.dir
    else:
        dest_dir = os.path.expanduser('~' + (opts.user if opts.user else ''))
    source_dir = os.path.abspath(os.path.dirname(__file__))

    # Get a dictionary with a list of ignore_patterns and copy_patterns.
    config = get_config(source_dir)

    processed_dirs = []
    for root, dirs, files in os.walk(source_dir, topdown=True):
        for item in chain(dirs, files):
            source = join(root, item)
            # Skip it if it's in a directory we've already linked or ignored
            if any(source.startswith(path) for path in processed_dirs):
                continue
            # Skip it if we've been told to ignore it
            if any(fnmatch(source, pat) for pat in config['ignore_patterns']):
                if isdir(source):
                    processed_dirs.append(source + os.sep)
                continue
            # Copy it if we've been told to copy it
            if any(fnmatch(source, pat) for pat in config['copy_patterns']):
                print('* copying on: ' + source)
                continue
            # Otherwise, create a symlink
            print('* SYM ' + join(dest_dir, source[len(source_dir)+1:]) + ' -> ' + source)
            if isdir(source):
                processed_dirs.append(source + os.sep)


if __name__ == '__main__':
    main(sys.argv)
