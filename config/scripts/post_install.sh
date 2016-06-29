echo '\nRemoving empty files in ~\n'
rm -R ~/Desktop ~/Music ~/Public ~/Videos ~/Documents ~/examples.desktop ~/Pictures ~/Templates

echo '\nInstall zsh...\n'
wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
chsh -s $(which zsh)

echo '\nSet default browser...\n'
sudo update-alternatives --config x-www-browser

echo '\nSet keygen for github:\n - file: /home/<user>/.ssh/id_rsa_github\n - passphrase: SKIP'
ssh-keygen -t rsa -b 4096

echo '\nSet keygen for bitbucket:\n - file: /home/<user>/.ssh/id_rsa_bitbucket\n - passphrase: SKIP'
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
echo '\nYou should check it out if adding system path to idea.sh would help with i3 hinting\n'




