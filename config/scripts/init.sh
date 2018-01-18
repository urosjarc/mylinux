echo "\nInstalling apt dependencies...\n"
sudo apt-get -y install python3.6-dev curl

echo "\nUpgrade pip...\n"
pip3 install --upgrade pip3

echo "\nInstalling pip dependencies...\n"
sudo pip3 install pylint docopt tabulate


echo "\nInstalling node dependencies...\n"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | sudo bash
