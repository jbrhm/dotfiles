#! /usr/bin/bash

set -euox pipefail

if [[ "$#" -ne 1 || ("$1" != "ubuntu") ]]; then
    echo "Usage: ./setup.sh <ubuntu>"
    exit 1
fi

echo "Running dotfiles setup for $1"

# get sudo permissions for apt installations
sudo -v

if ! command -v ansible --version >/dev/null 2>&1
then
    echo "ansible could not be found"
    if [ "$1" == "ubuntu" ]; then
	sudo apt install ansible -y
    else
        exit 1
    fi
fi


# run ansible script to install config dependencies
ansible-playbook $1/packages.yaml

pushd ..

# get nvim
stow nvim

# get tmux
stow tmux

# install tmux packages
echo "When opening tmux next press Ctrl + b follwed by Shift + I to install tmux packages"

# get terminator
stow terminator

# get i3
stow i3
