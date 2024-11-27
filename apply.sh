#!/bin/bash

nix run nix-darwin \
    --extra-experimental-features 'nix-command flakes' \
    -- switch --flake ~/dotfiles/nix/darwin

#Hello
