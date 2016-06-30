RED='\033[0;31m'
NC='\033[0m' # No Color

echo "\n${RED}Removing empty files in ~${NC}\n"
rm -r -i ~/Desktop 
rm -r -i ~/Music
rm -r -i ~/Public 
rm -r -i ~/Videos
rm -r -i ~/Documents 
rm -r -i ~/examples.desktop 
rm -r -i ~/Pictures 
rm -r -i ~/Templates

echo '\nInstall zsh...\n'
wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
chsh -s $(which zsh)

echo '\nSet default browser...\n'
sudo update-alternatives --config x-www-browser

echo "\nSet keygen for github:\n - file: ${RED}/home/<user>/.ssh/id_rsa_github${NC}\n - passphrase: ${RED}SKIP${NC}\n"
ssh-keygen -t rsa -b 4096

echo "\nSet keygen for bitbucket:\n - file: ${RED}/home/<user>/.ssh/id_rsa_bitbucket${NC}\n - passphrase: ${RED}SKIP${NC}\n"
ssh-keygen -t rsa -b 4096

echo '\nAdding .MY_login source to .profile file...\n'
grep -q -F 'source ~/.MY_login' ~/.profile || echo 'source ~/.MY_login' >> ~/.profile

echo '\nInstalling IDEA products\n'
wget -O ~/Downloads/intellij.tar.gz https://download-cf.jetbrains.com/idea/ideaIC-2016.1.3.tar.gz
wget -O ~/Downloads/pycharm.tar.gz https://download-cf.jetbrains.com/python/pycharm-community-2016.1.4.tar.gz
wget -O ~/Downloads/webstorm.tar.gz https://download-cf.jetbrains.com/webstorm/WebStorm-2016.1.3.tar.gz
mkdir ~/APPS
tar -xfz ~/Downloads/intelij.tar.gz -C ~/APPS
tar -xfz ~/Downloads/pycharm.tar.gz -C ~/APPS
tar -xfz ~/Downloads/webstorm.tar.gz -C ~/APPS

echo "\n${RED}Setting chmod(urosjarc,~/APPS)${NC}\n"
sudo chmod -R urosjarc: ~/APPS

echo '\nYou should check it out if adding system path to idea.sh would help with i3 hinting\n'


