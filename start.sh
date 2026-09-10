#!/usr/bin/env bash

set -e

printS () {
    printf "\n\n... %s ...\n\n" "$1"
    read -r -p "Press enter to continue"
}

open () {
    xdg-open "$1" > output.log 2>&1 &
}

printS "Install make"
sudo apt update
sudo apt install -y make

printS "Setup background images"
open /usr/share/backgrounds/
open ./data/background/

printS "Setup user info and versions"
open config/variables
open https://github.com/SSNikolaevich/DejaVuSansCode/releases
open https://developers.google.com/tink/tinkey-overview
open https://github.com/nvm-sh/nvm/releases
open https://www.jetbrains.com/pycharm/download/?section=linux
open https://www.jetbrains.com/idea/download/?section=linux
