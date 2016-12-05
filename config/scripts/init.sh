echo "\nInstalling apt dependencies...\n"
sudo apt-get -y install python-apt python-pip

echo "\nUpgrade pip...\n"
pip install --upgrade pip

echo "\nInstalling pip dependencies...\n"
sudo pip install pylint docopt tabulate
