echo "\nInstalling apt dependencies...\n"
sudo apt-get -y install python-apt python-pip

echo "\nInstalling pip dependencies...\n"
sudo pip install docopt==0.6.2 tabulate==0.7.5