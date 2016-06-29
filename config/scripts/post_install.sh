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