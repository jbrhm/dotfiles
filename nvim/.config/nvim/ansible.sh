#!/usr/bin/env bash

sudo -v

sudo apt update

sudo apt install git

echo What is your github email?

read githubEmail

ssh-keygen -t ed25519 -C "$githubEmail"

eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub

echo Copy this and paste it into your github SSH and GPG keys. Press Enter when done.

read dummy

echo What is your github username?

read githubUsername

git config --global user.name "$githubUsername"

git config --global user.email "$githubEmail"

sudo apt install ansible

ansible-playbook dev.yml
