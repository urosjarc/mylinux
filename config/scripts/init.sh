echo "\nInstalling apt dependencies...\n"
sudo apt-get -y install python-apt python-pip curl

echo "\nUpgrade pip...\n"
pip install --upgrade pip

echo "\nInstalling pip dependencies...\n"
sudo pip install pylint docopt tabulate


echo "\nInstalling node dependencies...\n"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | sudo bash
