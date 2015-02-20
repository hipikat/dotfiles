#!/usr/bin/env python
# coding=utf-8
"""
Deep-copy, move or symlink files and directories from one location to
another. By default directories are created recursively, and if a
destination file already exists, a warning is given and no action is taken.
"""
# "Awkardly designed to run without requiring any 3rd-party libraries."
#
# TODO: More docs. Then a ReadTheDocs link in the module docstring.
#
# Copyright © 2014, Adam Wright <adam@hipikat.org>
# All rights reserved. But here's the BSD 2-Clause License:
#
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
from os import path
import fnmatch
import json
import logging
import sys
import shutil


MODULE_DIR, MODULE_NAME = path.split(path.abspath(__file__))
DEFAULT_POLICY_FILE = path.splitext(path.abspath(__file__))[0] + '.json'
ACTIONS = ('copy', 'link', 'move', 'ignore')
DEFAULT_ACTION = 'copy'


####
# Command-line arguments
arg_parser = argparse.ArgumentParser(description=__doc__)

# Source - default to script directory if not provided
arg_parser.add_argument('-s', '--source', type=str, default=MODULE_DIR, metavar="DIR",
                        help="Base directory from which to apply actions on files. "
                        "(defaults to the directory containing "
                        "{} - currently {}).".format(MODULE_NAME, MODULE_DIR))

# Destination - mutually exclusive group of options
dest_group = arg_parser.add_mutually_exclusive_group(required=True)
dest_group.add_argument('-d', '--dest', type=str, metavar="DIR",
                        help="Destination directory for actions on files.")
dest_group.add_argument('-u', '--user', type=str,
                        help="Make ~USER the base destination for actions on files.")
dest_group.add_argument('-U', '--current-user', default=False, action='store_true',
                        help="Make the current user's home directory the base "
                        "destination for actions performed on files.")

# … and the other options, too.
arg_parser.add_argument('-p', '--policy_file', type=str,
                        help="Policy config file associating patterns with actions.")
arg_parser.add_argument('-f', '--force', default=False, action='store_true',
                        help="Overwrite existing files and links.")
arg_parser.add_argument('-V', '--verbose', default=False, action='store_true',
                        help="Print info when existing files are deleted or prevent actions.")


class FilePlumber(object):
    """
    Class for planning and executing the plumbing (i.e. copying, moving and
    symlinking) of files and directories from one location to another.
    """

    def __init__(self, source, dest, policy_file=None, force=None, **kwargs):
        """Set source and destination directories and get policies."""
        self.source = source
        self.dest = dest
        self.policies = self.SimplePolicies(policy_file=policy_file)
        # Command-line --force overrides any `force_all` value in the policy file.
        self.force_all = force if force is not None \
            else getattr(self.policies, 'force_all', False)

    class SimplePolicies(object):
        """
        Policies, i.e. 'move', 'copy', 'link' or 'ignore' associated with
        glob-like patterns, to be matched against files when plumbing them
        from a source to a destination directory tree.
        """
        default_action = None

        def __init__(self, default_action=None, policy_file=None):
            """Set a default action and policies, based on a file if one is given."""

            # Set basic, empty default policies so the following code can just
            # worry about resetting any which have been explicitly specified.
            self.default_action = default_action or DEFAULT_ACTION
            for action in ACTIONS:
                setattr(self, action, [])

            if policy_file:
                self.set_policies_from_file(policy_file)

        def set_policies_from_file(self, policy_file):
            """
            Copy attributes on `self` from `policy_file`, which is expected to be
            be a JSON file containing a single dict. The dict may contain any or
            all of `"default"` (a string matching one of the values in `ACTIONS`),
            `"copy"`, `"link"`, `"move"` and `"ignore"` (lists of 'glob' patterns
            to match files against).
            """
            try:
                with open(policy_file) as fp:
                    policy_spec = json.load(fp)
            except IOError:
                raise IOError("Couldn't read policy file {}".format(policy_file))

            if 'default' in policy_spec:
                if policy_spec['default'] not in ACTIONS:
                    raise AttributeError("Invalid default action '{}'; must be one of {}".format(
                        policy_spec['default'], str(ACTIONS)))
                self.default = policy_spec['default']

            self.force_all = bool(policy_spec['force_all']) if 'force_all' in policy_spec else None

            for action in ACTIONS:
                if action in policy_spec:
                    setattr(self, action, policy_spec[action][:])

        def get_policy(self, path):
            for action in ACTIONS:
                for glob in [glob_list for glob_list in getattr(self, action)]:
                    if fnmatch.fnmatchcase(path, glob):
                        return action
            return self.default

    # End of class SimplePolicies

    def plumb(self, dry_run=False):
        """
        Derive a set of planned `(self.)actions` based on `(self.)policies`,
        and execute them (or just pretend to, if `dry_run` is `True`).
        """
        action_list = self._get_action_list()
        self._execute_action_list(action_list, dry_run)

    def _get_action_list(self, rel_dir='', plan_so_far=None):
        """
        Return a flat-list of 2-tuples of the form `('relative/file/location', 'operation')`
        where 'operation' is one of 'copy', 'link', 'move' or 'ignore'. When a
        directory is marked for copy, recurse into its children - this effectively
        creates a depth-first tree of actions which chan be followed from top
        to bottom, to execute the policies dictated by a `SimplePolicies` object.
        """
        plan = plan_so_far if plan_so_far is not None else []
        for item in sorted(os.listdir(path.join(self.source, rel_dir))):
            rel_item = path.join(rel_dir, item)
            item_policy = self.policies.get_policy(rel_item)
            plan.append((rel_item, item_policy))
            # Recurse into children for 'copied' directories.
            # Every other operation is a dead-end.
            if path.isdir(path.join(self.source, rel_item)) and item_policy == 'copy':
                self._get_action_list(rel_item, plan)
        return plan

    def _execute_action_list(self, plan, dry_run=False):
        """
        Carry out (or just pretend, and give output) operations, recursively,
        on files from `self.source` to `source.dest`, based on `self.actions`.
        """
        for rel_item, action in plan:
            abs_dest = path.join(self.dest, rel_item)
            exists = True if path.lexists(abs_dest) else False
            self._run(action, rel_item, exists, self.force_all, dry_run)

    def _run(self, action, rel_path, dest_exists, force=False, dry_run=False, **kwargs):
        """
        E.g. _run('copy', 'foo/bar.baz', ...). The real, atomic operations get
        called from here if not dry_run.
        """
        if dest_exists:
            if not force:
                logging.info("Skipping {} of {} because destination exists.".format(
                    action, rel_path))
                return
            else:
                logging.info("Deleting existing {} before {} operation.".format(
                    rel_path, action))
                if not dry_run:
                    self._remove_item(path.join(self.dest, rel_path))
        self._log_run(action, rel_path=rel_path)
        if not dry_run:
            # Call one of the _run_[copy|link|move|ignore] methods defined below.
            getattr(self, '_run_' + action)(rel_path=rel_path)

    def _remove_item(self, abs_path):
        if path.isfile(abs_path) or path.islink(abs_path):
            os.remove(abs_path)
        elif path.isdir(abs_path):
            shutil.rmtree(abs_path)
        else:
            raise NotImplementedError("Unknown file type: " + abs_path)

    def _get_abs_paths(fn):
        """
        A decorator to wrap functions which take a `rel_path` - it adds
        `from_path` and `to_path to the keyword arguments by joining with the
        base paths `self.source` and `self.dest`, respectively.
        """
        def abs_fed_fn(self, *args, **kwargs):
            kwargs['from_path'] = path.join(self.source, kwargs['rel_path'])
            kwargs['to_path'] = path.join(self.dest, kwargs['rel_path'])
            return fn(self, *args, **kwargs)
        return abs_fed_fn

    _action_gerunds = {
        'copy': 'Copying',
        'link': 'Linking',
        'move': 'Moving',
        'ignore': 'Ignoring',
    }

    @_get_abs_paths
    def _log_run(self, action, rel_path, from_path, to_path):
        """
        Print a human-friendly description of an operation and its operands.
        (This is separate from the runners so we can print operations during a
        dry run and only bail out right before the operation itself.)
        """
        action_str = self._action_gerunds[action] + " " + from_path
        if action == 'ignore':
            logging.info(action_str)
        else:
            print(action_str + " to " + to_path)

    @_get_abs_paths
    def _run_copy(self, from_path, to_path, **kwargs):
        """
        If `from_path` is a directory, create a directory with the same name at
        `to_path`. Otherwise, copy the file at `from_path` to `to_path`.
        """
        os.mkdir(to_path) if path.isdir(from_path) else shutil.copy(from_path, to_path)

    @_get_abs_paths
    def _run_link(self, from_path, to_path, **kwargs):
        """Create a symbolic link pointing at `from_path` from `to_path`."""
        os.symlink(from_path, to_path)

    @_get_abs_paths
    def _run_move(self, from_path, to_path, **kwargs):
        """Move a file or directory from `from_path` to `to_path`."""
        shutil.move(from_path, to_path)

    def _run_ignore(self, rel_path, **kwargs):
        """Do absolutely nothing."""


def get_options_from_args(**kwargs):
    """
    Return an options dictionary suitable for initialisation of a `FilePlumber`
    object by parsing command line arguments (i.e. call `arg_parser.parse_args()`,
    then process and return the results).
    """
    args = arg_parser.parse_args()
    opts = dict()

    # Get destination directory. Options `dest`, `user` and `current_user` are
    # a mutually exclusive (but required) group, so one of those attributes on
    # args will have to be `not None`.
    opts['dest'] = args.dest
    if not opts['dest']:
        opts['dest'] = path.expanduser('~' + (args.user if args.user else ''))

    # Get policy file. If no policy file is specified and this module is
    # `plumb_files.py`, default to looking for a policy file by the name of
    # `plumb_files.json`, in the same directory as this file.
    opts['policy_file'] = args.policy_file
    if not opts['policy_file'] and path.exists(DEFAULT_POLICY_FILE):
        opts['policy_file'] = DEFAULT_POLICY_FILE

    # Get options which are correctly set by argparse
    for opt in ('source', 'force', 'verbose'):
        opts[opt] = getattr(args, opt)

    return opts


# Entry-point for command-line invocation of this module
def main(*argv, **kwargs):
    opts = get_options_from_args()

    if opts['verbose']:
        logging.getLogger().setLevel(logging.INFO)
    plumber = FilePlumber(**opts)
    plumber.plumb()

if __name__ == '__main__':
    main(sys.argv)
