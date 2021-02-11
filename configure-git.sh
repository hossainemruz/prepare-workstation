#!/bin/bash
set -eou pipefail

echo "Enter 'GIT_GLOBAL_USER_NAME'"
read GIT_GLOBAL_USER_NAME
echo "Enter 'GIT_GLOBAL_USER_EMAIL'"
read GIT_GLOBAL_USER_EMAIL

# configure git environment
git config --global user.name $GIT_GLOBAL_USER_NAME
git config --global user.email $GIT_GLOBAL_USER_EMAIL

echo "Generating new ssh-keys......"
ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -C "$GIT_GLOBAL_USER_EMAIL" -q -N "" || true
eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_ed25519
xclip -selection clipboard < $HOME/.ssh/id_ed25519.pub

echo "Succesfully configured git"
