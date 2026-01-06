#! /usr/bin/bash

set -Eeuo pipefail

readonly RED_BOLD='\033[1;31m'
readonly BLUE_BOLD='\033[1;34m'
readonly GREY_BOLD='\033[1;30m'
readonly YELLOW_BOLD='\033[1;33m'
readonly NC='\033[0m'

echo -e "${GREY_BOLD}Ensuring SSH keys are set up ...${NC}"
if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
  echo -e "${RED_BOLD}Please see: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent${NC}"
  exit 1
fi

PPAS=(
  ansible/ansible
  git-core/ppa
)
NEED_APT_UPDATE=false
for PPA in "${PPAS[@]}"; do
  if ! grep -q "^deb .*${PPA}" /etc/apt/sources.list /etc/apt/sources.list.d/*;
  then
    echo -e "${GREY_BOLD}Adding PPA: ${PPA}${NC}"
    sudo apt-add-repository ppa:"${PPA}" -y
    NEED_APT_UPDATE=true
  fi
done

if [ "${NEED_APT_UPDATE}" = true ]; then
    sudo apt update
fi
sudo apt install -y ansible git git-lfs
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
    if [ "$1" == "ubuntu-install" ]; then
        sudo apt install git ansible -y

        git clone git@github.com:jbrhm/dotfiles.git

        pushd dotfiles/setup
    elif [ "$1" == "ubuntu" ]; then
        sudo apt install ansible -y
    else
        exit 1
    fi
fi


# run ansible script to install config dependencies
ansible-playbook $1/packages.yaml

pushd ~

mkdir -p ~/obsidian

pushd obsidian

git clone git@github.com:jbrhm/Obsidian-Main.git

pushd ~/dotfiles

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

# get zsh
stow zsh

# install nerd font
wget -O ~/Downloads/jetbrains.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
unzip ~/Downloads/jetbrains.zip -d ~/.fonts
fc-cache -fv

pushd ~

# install mrover
./dotfiles/setup/files/mrover/bootstrap.sh

# install nvidia drivers
sudo apt update
ubuntu-drivers devices
sudo ubuntu-drivers install
