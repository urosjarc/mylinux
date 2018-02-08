echo '\n...CUSTOM INSTALL...\n'
wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting


echo '\n...I3 LOCK SCREEN...\n'
git clone https://github.com/guimeira/i3lock-fancy-multimonitor.git ~/.i3/i3lock-fancy-multimonitor
sudo chmod +x ~/.i3/i3lock-fancy-multimonitor/lock



echo '\n...LIGHT...\n'
git clone https://github.com/haikarainen/light ~/.APPS/light
cd ~/.APPS/light
	sudo apt-get install help2man -y
	sudo make
	sudo make install
cd ~

echo '\n...KIVY DESIGNER...\n'
git clone https://github.com/kivy/kivy-designer ~/.APPS/kivy-designer
sudo pip install -Ur ~/.APPS/kivy-designer/requirements.txt
garden install xpopup


echo '\n...TAR INSTALL...\n'
mkdir -p ~/.APPS
wget -O ~/Downloads/pycharm.tar.gz 	    https://download-cf.jetbrains.com/python/pycharm-community-2017.3.2.tar.gz
wget -O ~/Downloads/gitkraken.tar.gz    https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz

tar -xf ~/Downloads/pycharm.tar.gz -C ~/.APPS
tar -xf ~/Downloads/gitkraken.tar.gz -C ~/.APPS



echo '\n...SYSTEM CONFIG...\n'
sudo grep -q -F 'fs.inotify.max_user_watches' /etc/sysctl.conf || echo 'fs.inotify.max_user_watches = 524288' | sudo tee --append /etc/sysctl.conf > /dev/null
sudo sysctl -p #Update inotify
sudo update-alternatives --config x-www-browser
sudo -u urosjarc -H sh -c "chsh -s $(which zsh)"



echo '\n...UPDATE FILE SYSTEM...\n'
rm -rf ~/Desktop
rm -rf ~/Music
rm -rf ~/Public
rm -rf ~/Videos
rm -rf ~/Documents
rm -rf ~/Pictures
rm -rf ~/Templates
rm -rf ~/examples.desktop
mkdir ~/vcs


echo '\n...VERSION CONTROL SYSTEM...\n'
git clone https://github.com/urosjarc/mylinux.git ~/vcs/mylinux
git clone https://github.com/urosjarc/jetbrains.git ~/vcs/jetbrains
git clone https://github.com/urosjarc/wallet.git ~/vcs/wallet
git clone https://github.com/urosjarc/heart.git ~/vcs/heart



echo '\n...SET AUTHOR PERMISSIONS...\n'
sudo chown -R urosjarc: ~
