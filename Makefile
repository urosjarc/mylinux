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

.DEFAULT_GOAL := run-min
.PHONY: data

#==================================================================
### Running whole installation procedure ##########################
#==================================================================

run-select: ##Select which targets you want to run.
	
	$(MAKE) $(shell whiptail --title "Select target to install" --checklist "Choose:" 20 30 15 \
	  "setup" "" on \
	  "install" "" on \
	  "install-opt" "" off \
	  "update" "" on \
	  "post-install" "" on \
	  "post-setup" "" on \
	  "data" "" on \
	  "vcs" "" on \
	  "finish" "" on \
	  3>&1 1>&2 2>&3)

run-min: setup install		   update post-install post-setup data vcs finish ##Run minimalistic installation set
run-all: setup install install-opt update post-install post-setup data vcs finish ##Run whole installation set.

#=====================================================================
### Setup requirements for installation procedures ###################
#=====================================================================

setup: setup-apt setup-npm setup-dirs

setup-apt: ##Add all repositories to apt.
	
	$(call INFO, SETUP APT REPOS)
		add-apt-repository -y ppa:danielrichter2007/grub-customizer					# Grub customizer
		add-apt-repository -y ppa:yannubuntu/boot-repair						# Boot repair
		add-apt-repository -y ppa:nilarimogard/webupd8							# Audacity, woeusb
		add-apt-repository -y ppa:maarten-fonville/android-studio					# Android studio
		add-apt-repository -y "deb http://archive.canonical.com $(shell lsb_release -sc) partner"	# Flash plugins (firefox, chrome)

	$(call INFO, SETUP neo4j SOURCES)
		wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
		echo 'deb http://debian.neo4j.org/repo stable/' > /tmp/neo4j.list
		mv /tmp/neo4j.list /etc/apt/sources.list.d

setup-npm: ##Install NVM
	
	$(call INFO, INSTALL NVM)
		wget -O- https://raw.githubusercontent.com/nvm-sh/nvm/$(NVM)/install.sh | bash
		. ~/.nvm/nvm.sh

	$(call INFO, INSTALL NODE LTS)
		nvm install --lts

	$(call INFO, UPGRADE NPM)
		nvm install-latest-npm

setup-dirs:
	$(call INFO, SETUP SOFT LINKS)
		ln -sfn $(shell find ~/.nvm/versions/node -regex '.*\/v[0-9\.]+\/bin\/node') "/usr/local/bin/node"
		ln -sfn $(shell find ~/.nvm/versions/node -regex '.*\/v[0-9\.]+\/bin\/npm') "/usr/local/bin/npm"
	
	$(call INFO, CREATING .APPS DIR)
		mkdir -p $(APPS)

#=====================================================
### Update various package managers ##################
#=====================================================

update: update-npm update-pip3 update-gem update-apt

update-npm:
	$(call INFO, UPDATE NPM)
		npm install -g npm

update-pip3:
	$(call INFO, UPDATE PIP3)
		sudo -H pip3 install --upgrade setuptools pip

update-gem:
	$(call INFO, UPDATE GEM)
		gem update

update-apt:
	$(call INFO, UPDATE APT)
		apt-get update


#===========================================
### Installation procedure #################
#===========================================

install: install-apt install-npm install-pip3 install-gem install-apps-gitkraken install-apps-pycharm

install-apt:
	$(call INFO, INSTALL APT PACKAGES)
		$(call INSTALL,apt-get -y install,apt)

install-npm:
	$(call INFO, INSTALL NPM PACKAGES)
		$(call INSTALL,npm install -g,npm)

install-pip3:
	$(call INFO, INSTALL PIP3 PACKAGES)
		$(call INSTALL,pip3 install,pip3)

install-gem:
	$(call INFO, INSTALL GEM PACKAGES)
		$(call INSTALL,gem install,gem)

install-apps-gitkraken:
	$(call INFO, INSTALL GITKRAKEN)
		$(call WGET_APP,gitkraken.tar.gz,https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz)
		ln -sfn $(APPS)/gitkraken/gitkraken /usr/local/bin/gitkraken

install-apps-pycharm:
	$(call INFO, INSTALL PYCHARM)
		$(call WGET_APP,pycharm.tar.gz,https://download.jetbrains.com/python/pycharm-community-$(PYCHARM).tar.gz)
		ln -sfn $(APPS)/pycharm-community-$(PYCHARM)/bin/pycharm.sh /usr/local/bin/pycharm

install-opt: install-apt-optional install-apps-intellij

install-apt-optional:
	$(call INFO, INSTALL APT PACKAGES)
		$(call INSTALL,apt-get -y install,apt-optional)
		ln -sfn /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio

install-apps-intellij:
	$(call INFO, INSTALL INTELLIJ)
		$(call WGET_APP,intellij.tar.gz,https://download.jetbrains.com/idea/ideaIC-$(IDEA).tar.gz)
		ln -sfn $(APPS)/ideaIC-$(IDEA)/bin/idea.sh') /usr/local/bin/idea

#============================================
### Post installation procedures ############
#============================================

post-install: ##Install zsh, i3, heroku.
	
	$(call INFO, POST INSTALL ZSH TOOLS)
		wget -O- https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
		$(call GIT_CLONE,https://github.com/zsh-users/zsh-syntax-highlighting.git,~/.oh-my-zsh/plugins/zsh-syntax-highlighting)

	$(call INFO, POST INSTALL I3 TOOLS)
		$(call GIT_CLONE,https://github.com/guimeira/i3lock-fancy-multimonitor.git,~/.i3/i3lock-fancy-multimonitor)
		chmod +x ~/.i3/i3lock-fancy-multimonitor/lock

	$(call INFO, POST INSTALL HEROKU)
		wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh

	$(call INFO, INSTALL CODE FONTS)
		$(call WGET_APP,dejavu-code-ttf,https://github.com/SSNikolaevich/DejaVuSansCode/releases/download/v$(CODE_FONTS)/dejavu-code-ttf-$(CODE_FONTS).tar.bz2)
		cp $(APPS)/dejavu-code-ttf-$(CODE_FONTS)/ttf/* /usr/local/share/fonts
		fc-cache -f
		echo " ?? Installed fonts (DejaVuSansCode):"
		fc-list | grep "DejaVuSansCode"

#====================================================
### Post installation setup procedures ##############
#====================================================

post-setup: ##Setup inotify, alternatives, vcs, clean home directory.
	
	$(call INFO, SETUP INOTIFY)
		grep -q -F 'fs.inotify.max_user_watches' /etc/sysctl.conf || echo 'fs.inotify.max_user_watches = 524288' | sudo tee --append /etc/sysctl.conf > /dev/null
		sysctl -p #Update inotify

	$(call INFO, POST CLEANING HOME DIRECTORY)
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
		update-alternatives --config x-terminal-emulator

	$(call INFO, POST SETUP SHELL)
		grep $(USER) /etc/passwd
		usermod --shell $(shell which zsh) $(USER)
		grep $(USER) /etc/passwd

#=====================================================================
### Setup and copy all dotfiles to home directory ####################
#=====================================================================

data: ##Setup i3 background, layouts, and dotfiles.
	
	$(call INFO, COPY BACKGROUND)
		cp -r $(BACKGROUND) ~/.i3

	$(call INFO, COPY LAYOUTS)
		cp -r $(LAYOUTS) ~/.i3

	$(call INFO, COPY DOTFILES)
		$(value CP_DOTFILES)

#=====================================================================
### Setup your own vcs ####################
#=====================================================================

vcs: vcs-setup vcs-jetbrains

vcs-setup: ##Create vcs directory and clone repos.
	
	$(call INFO, POST SETUP VCS)
		mkdir -p $(VCS)
		$(call GIT_CLONE,https://github.com/$(USER)/mylinux.git,$(VCS)/mylinux)
		$(call GIT_CLONE,https://github.com/$(USER)/jetbrains.git,$(VCS)/jetbrains)

vcs-jetbrains: ##Install jetbrains repo.
	
	$(call INFO, POST SETUP JETBRAINS)
		cd $(VCS)/jetbrains; make install

#=====================================================================
### Finish procedure #################################################
#=====================================================================
	
finish: ##Finish procedure (user permissions, rebooting)
	$(call INFO, POST SETUP CHOWN HOME DIR)
		chown -R $(USER) $(HOME)

	$(call INFO, SETUP MATLAB)
		read -p "Setup Matlab? (y/n)" -n 1 -r
		if [[ $REPLY =~ ^[Yy] ]]; then $(MAKE) matlab; fi

	$(call INFO, RESTARTING)
		read -p "Reboot the sistem? (y/n)" -n 1 -r
		if [[ $REPLY =~ ^[Yy] ]]; then reboot; fi
	

#=====================================================================
### MATLAB procedure #################################################
#=====================================================================

matlab: ##Create matlab binary
	$(call INFO, CREATE MATLAB LINKS)
		ln -sfn $(APPS)/MATLAB/$(MATLAB)/bin/matlab /usr/local/bin/matlab
		ls -la /usr/local/bin | grep "matlab"












