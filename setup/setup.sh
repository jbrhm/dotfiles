#! /usr/bin/bash

set -euox pipefail

echo "Running dotfiles setup for $1"

if ! command -v ansible --version >/dev/null 2>&1
then
    echo "ansible could not be found"
    exit 1
fi

# get sudo permissions for apt installations
sudo -v

# run ansible script to install config dependencies
ansible-playbook $1/packages.yaml
