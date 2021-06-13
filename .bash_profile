# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

if [[ -d "$HOME/.pyenv" ]]; then
    PYENV_ROOT="$HOME/.pyenv"
    PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
fi

# If we're running bash, include .bashrc if it exists
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
	    . "$HOME/.bashrc"
    fi
fi
