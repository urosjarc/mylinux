RED='\033[0;31m'
NC='\033[0m' # No Color



echo '\n...CUSTOM INSTALL...\n'
wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash
nvm install node
sudo npm update npm -g



echo '\n...TAR INSTALL...\n'
mkdir ~/.APPS
wget -O ~/Downloads/intellij.tar.gz 	https://download-cf.jetbrains.com/idea/ideaIC-2016.2.4.tar.gz
wget -O ~/Downloads/pycharm.tar.gz 	https://download-cf.jetbrains.com/python/pycharm-community-2016.2.3.tar.gz
wget -O ~/Downloads/webstorm.tar.gz 	https://download-cf.jetbrains.com/webstorm/WebStorm-2016.2.3.tar.gz
sudo tar -xf ~/Downloads/intellij.tar.gz -C ~/.APPS
sudo tar -xf ~/Downloads/pycharm.tar.gz -C ~/.APPS
sudo tar -xf ~/Downloads/webstorm.tar.gz -C ~/.APPS



echo '\n...SYSTEM CONFIG...\n'
sudo grep -q -F 'fs.inotify.max_user_watches' /etc/sysctl.conf || echo 'fs.inotify.max_user_watches = 524288' | sudo tee --append /etc/sysctl.conf > /dev/null
sudo sysctl -p #Update inotify
sudo update-alternatives --config x-www-browser
sudo -u urosjarc -H sh -c "chsh -s $(which zsh)"



echo '\n...SSH CONFIG....\n'
mkdir ~/.ssh
echo "\nSet keygen for github:\n - file: ${RED}/home/<user>/.ssh/id_rsa_github${NC}\n - passphrase: ${RED}SKIP${NC}\n"
ssh-keygen -t rsa -b 4096
echo "\nSet keygen for bitbucket:\n - file: ${RED}/home/<user>/.ssh/id_rsa_bitbucket${NC}\n - passphrase: ${RED}SKIP${NC}\n"
ssh-keygen -t rsa -b 4096



echo '\n...UPDATE FILE SYSTEM...\n'
rm -rf ~/Desktop
rm -rf ~/Music
rm -rf ~/Public
rm -rf ~/Videos
rm -rf ~/Documents
rm -rf ~/Pictures
rm -rf ~/Templates
rm -rf ~/examples.desktop
sudo chown -R urosjarc: ~