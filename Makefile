include config/utils
include config/variables
include config/functions

IS_ROOT = $(shell id -u)
ifneq ($(IS_ROOT), 0)
$(error This script must be run as root)
endif

SUDO_HOME = $(shell sudo -H echo $(HOME))
ifneq ($(SUDO_HOME), $(HOME))
$(error SUDO_HOME "$(SUDO_HOME)" is not equal to "$(HOME)")
endif

.DEFAULT_GOAL := run-min
.PHONY: data

#==================================================================
### Running whole installation procedure ##########################
#==================================================================

run-select: ##Select which targets you want to run.
	$(MAKE) $$(whiptail --title "Select target to install" --checklist "Choose:" 20 30 15 \
		"setup" "" on \
		"install" "" on \
		"install-opt" "" off \
		"update" "" off \
		"post-install" "" on \
		"post-setup" "" on \
		"data" "" on \
		"vcs" "" on \
		"matlab" "" on \
		"finish" "" on \
		3>&1 1>&2 2>&3)

run-min: setup install             update post-install post-setup data vcs matlab finish ##Run minimalistic installation set
run-all: setup install install-opt update post-install post-setup data vcs matlab finish ##Run whole installation set.

#=====================================================================
### Setup requirements for installation procedures ###################
#=====================================================================

setup: setup-apt setup-npm setup-dirs

setup-apt: ##Add all repositories to apt.
	$(call TITLE, SETUP APT REPOS)
		add-apt-repository -y ppa:danielrichter2007/grub-customizer                                 # Grub customizer
		add-apt-repository -y ppa:yannubuntu/boot-repair                                            # Boot repair
		add-apt-repository -y ppa:nilarimogard/webupd8                                              # Audacity, woeusb
		add-apt-repository -y ppa:maarten-fonville/android-studio                                   # Android studio
		add-apt-repository -y "deb http://archive.canonical.com $$(lsb_release -sc) partner"	# Flash plugins (firefox, chrome)

	$(call TITLE, SETUP NEO4J SOURCES)
		wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
		echo 'deb http://debian.neo4j.org/repo stable/' > /tmp/neo4j.list
		echo
		$(call INFO,$$(mv -v /tmp/neo4j.list /etc/apt/sources.list.d))

setup-npm: ##Install NVM
	$(call TITLE, INSTALL NVM)
		wget -O- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM}/install.sh | bash
		. ~/.nvm/nvm.sh

	$(call TITLE, INSTALL NODE LTS)
		nvm install --lts

	$(call TITLE, UPGRADE NPM)
		nvm install-latest-npm

setup-dirs:
	$(call TITLE, SETUP SOFT LINKS)
		$(call LINK_BIN,$$(find $(HOME)/.nvm/versions/node -regex '.*\/v[0-9\.]+\/bin\/node'),)
		$(call LINK_BIN,$$(find $(HOME)/.nvm/versions/node -regex '.*\/v[0-9\.]+\/bin\/npm'),)
		echo
		$(call INFO,node ($$(node -v)))
		$(call INFO,npm ($$(npm -v)))

	$(call TITLE, CREATING .APPS DIR)
		$(call MKDIR,$(APPS))

#=====================================================
### Update various package managers ##################
#=====================================================

update: update-npm update-pip3 update-gem update-apt

update-npm:
	$(call TITLE, UPDATE NPM)
		npm install -g npm

update-pip3:
	$(call TITLE, UPDATE PIP3)
		sudo -H pip3 install --upgrade setuptools pip

update-gem:
	$(call TITLE, UPDATE GEM)
		gem update

update-apt:
	$(call TITLE, UPDATE APT)
		apt-get update

#===========================================
### Installation procedure #################
#===========================================

install: install-apt install-npm install-pip3 install-gem install-apps-gitkraken install-apps-pycharm

install-apt:
	$(call TITLE, INSTALL APT PACKAGES)
		$(call INSTALL,apt-get -y install,apt)

install-npm:
	$(call TITLE, INSTALL NPM PACKAGES)
		$(call INSTALL,npm install -g,npm)

install-pip3:
	$(call TITLE, INSTALL PIP3 PACKAGES)
		$(call INSTALL,pip3 install,pip3)

install-gem:
	$(call TITLE, INSTALL GEM PACKAGES)
		$(call INSTALL,gem install,gem)

install-apps-gitkraken:
	$(call TITLE, INSTALL GITKRAKEN)
		$(call WGET_APP,gitkraken.tar.gz,https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz)
		$(call LINK_BIN,$(APPS)/gitkraken/gitkraken,gitkraken)
		$(call INFO,gitkraken ($$(gitkraken -v)))

install-apps-pycharm:
	$(call TITLE, INSTALL PYCHARM)
		$(call WGET_APP,pycharm.tar.gz,https://download.jetbrains.com/python/pycharm-community-$(PYCHARM).tar.gz)
		$(call LINK_BIN,$(APPS)/pycharm-community-$(PYCHARM)/bin/pycharm.sh,pycharm)

install-opt: install-apt-optional install-apps-intellij

install-apt-optional:
	$(call TITLE, INSTALL APT PACKAGES)
		$(call INSTALL,apt-get -y install,apt-optional)
		echo
		$(call LINK_BIN,/opt/android-studio/bin/studio.sh,android-studio)

install-apps-intellij:
	$(call TITLE, INSTALL INTELLIJ)
		$(call WGET_APP,intellij.tar.gz,https://download.jetbrains.com/idea/ideaIC-$(IDEA).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/idea-IC-.*/bin/idea.sh'),idea)

#============================================
### Post installation procedures ############
#============================================

post-install: ##Install zsh, i3, heroku.
	$(call TITLE, POST INSTALL ZSH TOOLS)
		wget -O- https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
		$(call GIT_CLONE,https://github.com/zsh-users/zsh-syntax-highlighting.git,~/.oh-my-zsh/plugins/zsh-syntax-highlighting)

	$(call TITLE, POST INSTALL I3 TOOLS)
		$(call GIT_CLONE,https://github.com/guimeira/i3lock-fancy-multimonitor.git,~/.i3/i3lock-fancy-multimonitor)
		chmod -v +x ~/.i3/i3lock-fancy-multimonitor/lock

	$(call TITLE, POST INSTALL HEROKU)
		wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh

	$(call TITLE, INSTALL CODE FONTS)
		$(call WGET_APP,dejavu-code-ttf,https://github.com/SSNikolaevich/DejaVuSansCode/releases/download/v$(CODE_FONTS)/dejavu-code-ttf-$(CODE_FONTS).tar.bz2)
		cp -v $(APPS)/dejavu-code-ttf-$(CODE_FONTS)/ttf/* /usr/local/share/fonts
		fc-cache -f
		echo
		$(call INFO,'Installed fonts (DejaVuSansCode):')
		fc-list | grep "DejaVuSansCode"

#====================================================
### Post installation setup procedures ##############
#====================================================

post-setup: ##Setup inotify, alternatives, vcs, clean home directory.
	$(call TITLE, SETUP INOTIFY)
		grep -q -F 'fs.inotify.max_user_watches' /etc/sysctl.conf || echo 'fs.inotify.max_user_watches = 524288' | sudo tee --append /etc/sysctl.conf > /dev/null
		sysctl -p #Update inotify

	$(call TITLE, POST CLEANING HOME DIRECTORY)
		rm -rfv ~/Desktop
		rm -rfv ~/Music
		rm -rfv ~/Public
		rm -rfv ~/Videos
		rm -rfv ~/Documents
		rm -rfv ~/Pictures
		rm -rfv ~/Templates
		rm -rfv ~/examples.desktop
		$(call INFO,Home directory: $$(ls -l $(HOME))

	$(call TITLE, POST SETUP ALTERNATIVES)
		update-alternatives --config x-www-browser
		update-alternatives --config x-terminal-emulator

	$(call TITLE, POST SETUP SHELL)
		$(call INFO,$$(grep $(USER) /etc/passwd | sed -e 's/.*,,,://g'))
		usermod --shell $$(which zsh) $(USER)
		$(call INFO,$$(grep $(USER) /etc/passwd | sed -e 's/.*,,,://g'))

#=====================================================================
### Setup and copy all dotfiles to home directory ####################
#=====================================================================

data: ##Setup i3 background, layouts, and dotfiles.
	$(call TITLE, COPY BACKGROUND)
		cp -rv $(BACKGROUND) ~/.i3

	$(call TITLE, COPY LAYOUTS)
		cp -rv $(LAYOUTS) ~/.i3

	$(call TITLE, COPY DOTFILES)
		for fpath in $(DOTFILES)/*; do
			newPath=$$(echo $$fpath | sed -e 's/^.*\///g' -e 's/_|_/\//g' -e "s/~/\/home\/${USER}/g")
			$(call MKDIR,$$(dirname $$newPath))
			cp -v $$fpath $$newPath
		done

#=====================================================================
### Setup your own vcs ####################
#=====================================================================

vcs: vcs-setup vcs-jetbrains

vcs-setup: ##Create vcs directory and clone repos.
	$(call TITLE, POST SETUP VCS)
		$(call MKDIR,$(VCS))
		$(call GIT_CLONE,https://github.com/$(USER)/mylinux.git,$(VCS)/mylinux)
		$(call GIT_CLONE,https://github.com/$(USER)/jetbrains.git,$(VCS)/jetbrains)

vcs-jetbrains: ##Install jetbrains repo.
	$(call TITLE, POST SETUP JETBRAINS)
		cd $(VCS)/jetbrains; make install

#=====================================================================
### Matlab procedure #################################################
#=====================================================================

matlab: ##Create matlab binary
	$(call TITLE, SETUP MATLAB)
		read -p "Setup Matlab? (y/n): " -n 1 -r
		if [[ $$REPLY =~ ^[Yy] ]]
		then
			echo
			$(call LINK_BIN,$(APPS)/MATLAB/$(MATLAB)/bin/matlab,matlab)
			$(call INFO,Scripts: $(shell ls /usr/local/bin | grep "matlab"))
		fi

#=====================================================================
### Finish procedure #################################################
#=====================================================================

finish: ##Finish procedure (user permissions, rebooting)
	$(call TITLE, POST SETUP CHOWN HOME DIR)
		chown -R $(USER) $(HOME)
		$(call INFO,Folder $(HOME) now belongs to $(USER))

	$(call TITLE, RESTARTING)
		read -p "Reboot the sistem? (y/n): " -n 1 -r
		if [[ $$REPLY =~ ^[Yy] ]]; then
			echo
			reboot
		fi

