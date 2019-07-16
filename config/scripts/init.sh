echo "\nInstalling apt dependencies...\n"
sudo apt-get -y install python3-pip curl


echo "\nInstalling pip dependencies...\n"
sudo pip3 install docopt tabulate


echo "\nInstalling node dependencies...\n"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | sudo bash
reset
