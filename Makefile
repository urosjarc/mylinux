include config/utils
include config/variables
include config/functions

IS_ROOT = $(shell id -u)
ifneq ($(IS_ROOT), 0)
$(error This script must be run as root)
endif

SUDO_HOME = $(shell sudo -H echo $(HOME))
ifneq ($(SUDO_HOME), /home/$(USER))
$(error SUDO_HOME "$(SUDO_HOME)" is not equal to "/home/$(USER)")
endif

.DEFAULT_GOAL := all
.PHONY: data

all: setup install update post-install post-setup data

#============================
### setup ###################
#============================

setup: setup-apt setup-nvm

setup-apt:
	$(call INFO, SETUP APT REPOS)
		add-apt-repository -y ppa:yannubuntu/boot-repair						# Boot repair
		add-apt-repository -y ppa:nilarimogard/webupd8							# Audacity, woeusb
		add-apt-repository -y ppa:maarten-fonville/android-studio					# Android studio
		add-apt-repository -y "deb http://archive.canonical.com $(shell lsb_release -sc) partner"	# Flash plugins (firefox, chrome)

	$(call INFO, SETUP neo4j SOURCES)
		wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
		echo 'deb http://debian.neo4j.org/repo stable/' > /tmp/neo4j.list
		mv /tmp/neo4j.list /etc/apt/sources.list.d

setup-nvm:
	$(call INFO, INSTALL NVM)
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$(NVM)/install.sh | bash

	$(call INFO, SETUP EXE LINKS)
		ln -sfn $(shell find ~/.nvm/versions/node -regex '.*\/v[0-9\.]+\/bin\/node') "/usr/local/bin/node"
		ln -sfn $(shell find ~/.nvm/versions/node -regex '.*\/v[0-9\.]+\/bin\/npm') "/usr/local/bin/npm"

#============================
### update ##################
#============================

update: update-pip3 update-npm update-gem update-apt


update-npm:
	$(call INFO, UPDATE NPM)
		npm install -g npm

update-pip3:
	$(call INFO, UPDATE PIP3)
		pip3 install --upgrade setuptools pip

update-gem:
	$(call INFO, UPDATE GEM)
		gem update

update-apt:
	$(call INFO, UPDATE APT)
		apt-get update


#============================
### install #################
#============================

install: install-pip3 install-npm install-APPS install-apt install-gem

install-npm:
	$(call INFO, INSTALL NPM PACKAGES)
		$(call INSTALL,npm install -g,npm)

install-pip3:
	$(call INFO, INSTALL PIP3 PACKAGES)
		$(call INSTALL,pip3 install,pip3)

install-gem:
	$(call INFO, INSTALL GEM PACKAGES)
		$(call INSTALL,gem install,gem)

install-APPS:
	$(call INFO, CREATING .APPS DIR)
		mkdir -p ~/.APPS

	$(call INFO, INSTALL GITKRAKEN)
		$(call WGET_APP,gitkraken.tar.gz,https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz)

	$(call INFO, INSTALL INTELLIJ)
		$(call WGET_APP,intellij.tar.gz,https://download.jetbrains.com/idea/ideaIC-2019.1.tar.gz)

	$(call INFO, INSTALL PYCHARM)
		$(call WGET_APP,pycharm.tar.gz,https://download.jetbrains.com/python/pycharm-community-2019.1.1.tar.gz)

install-apt:
	$(call INFO, INSTALL APT PACKAGES)
		$(call INSTALL,apt-get -y install,apt)

#============================
### post-install ############
#============================

post-install:
	$(call INFO, POST INSTALL ZSH TOOLS)
		wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting

	$(call INFO, POST INSTALL I3 TOOLS)
		git clone https://github.com/guimeira/i3lock-fancy-multimonitor.git ~/.i3/i3lock-fancy-multimonitor
		chmod +x ~/.i3/i3lock-fancy-multimonitor/lock

	$(call INFO, POST INSTALL HEROKU)
		wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

#============================
### post-setup ##############
#============================

post-setup:
	$(call INFO, SETUP INOTIFY)
		grep -q -F 'fs.inotify.max_user_watches' /etc/sysctl.conf || echo 'fs.inotify.max_user_watches = 524288' | sudo tee --append /etc/sysctl.conf > /dev/null
		sysctl -p #Update inotify

	$(call INFO, POST SETUP CLEANING)
		rm -rf ~/Desktop
		rm -rf ~/Music
		rm -rf ~/Public
		rm -rf ~/Videos
		rm -rf ~/Documents
		rm -rf ~/Pictures
		rm -rf ~/Templates
		rm -rf ~/examples.desktop

	$(call INFO, POST SETUP ALTERNATIVES)
		update-alternatives --config x-www-browser
		sudo -u $(USER) -H sh -c "chsh -s $(which zsh)"

	$(call INFO, POST SETUP VCS)
		mkdir -p ~/vcs
		git clone https://github.com/$(USER)/mylinux.git ~/vcs/mylinux
		git clone https://github.com/$(USER)/jetbrains.git ~/vcs/jetbrains

#============================
### data ####################
#============================

data:
	$(call INFO, COPY BACKGROUND)
		cp -r $(BACKGROUND) ~/.i3/background

	$(call INFO, COPY LAYOUTS)
		cp -r $(LAYOUTS) ~/.i3/layouts

	$(call INFO, COPY DOTFILES)
		$(value CP_DOTFILES)


















