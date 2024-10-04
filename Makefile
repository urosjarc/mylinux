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

.DEFAULT_GOAL := run
.PHONY: data config

run: setup install install-apps post-install post-setup data vcs finish ##Run default installation set

#=====================================================================
### Setup requirements for installation procedures ###################
#=====================================================================

setup: setup-apt setup-dirs

setup-apt: ##Add all repositories to apt
	$(call TITLE, UPDATE APT)
		apt-get update

setup-dirs: ##Create folder for tar apps to install in
	$(call TITLE, CREATING .APPS DIR)
		$(call MKDIR,$(APPS))

#=====================================================
### Update various package managers ##################
#=====================================================

update: update-apt

update-apt:
	$(call TITLE, UPDATE APT)
		apt-get update

#===========================================
### Installation for package managers ######
#===========================================

install: install-drivers install-apt install-snap install-nvm

install-drivers:
	$(call TITLE, INSTALL DRIVERS)
		ubuntu-drivers autoinstall

install-apt:
	$(call TITLE, INSTALL APT PACKAGES)
		$(call INSTALL,apt-get -y install,apt)

install-snap:
	$(call TITLE, INSTALL SNAP PACKAGES)
		$(call INSTALL_LOOP,snap install --classic,snap)

install-nvm:
	$(call TITLE, INSTALL NPM)
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$(NVM)/install.sh | bash

#===========================================
### Installation for applications ##########
#===========================================

install-apps: install-apps-intellij install-apps-docker

install-apps-intellij:
	$(call TITLE, INSTALL INTELLIJ)
		$(call WGET_TAR,intellij.tar.gz,https://download.jetbrains.com/idea/ideaIU-$(IDEA).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/idea-IU-.*/bin/idea.sh'),idea)

install-apps-pycharm:
	$(call TITLE, INSTALL PYCHARM)
		$(call WGET_TAR,pycharm.tar.gz,https://download.jetbrains.com/python/pycharm-community-$(PYCHARM).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/pycharm-.*/bin/pycharm.sh'),pycharm)

install-apps-docker:
	$(call TITLE, INSTALL DOCKER)
		curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
		sh /tmp/get-docker.sh
		apt install docker-compose

#============================================
### Post installation procedures ############
#============================================

post-install: ##Install zsh, fonts
	$(call TITLE, POST APT AUTOREMOVE)
		apt autoremove

	$(call TITLE, POST INSTALL ZSH TOOLS)
		wget -O- https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
		echo
		$(call GIT_CLONE,https://github.com/zsh-users/zsh-syntax-highlighting.git,~/.oh-my-zsh/plugins/zsh-syntax-highlighting)

	$(call TITLE, POST INSTALL CODE FONTS)
		$(call WGET_TAR,dejavu-code-ttf,https://github.com/SSNikolaevich/DejaVuSansCode/releases/download/v$(CODE_FONTS)/dejavu-code-ttf-$(CODE_FONTS).tar.bz2)
		cp -v $(APPS)/dejavu-code-ttf-$(CODE_FONTS)/ttf/* /usr/local/share/fonts
		fc-cache -f
		echo
		$(call INFO,installed fonts [DejaVuSansCode])
		fc-list | grep "DejaVuSansCode"

#====================================================
### Post installation setup procedures ##############
#====================================================

post-setup: ##Setup inotify, alternatives, vcs, clean home directory
	$(call TITLE, POST SETUP INOTIFY)
		grep -q -F 'fs.inotify.max_user_watches' /etc/sysctl.conf || echo 'fs.inotify.max_user_watches = 524288' | sudo tee --append /etc/sysctl.conf > /dev/null
		sysctl -p #Update inotify

	$(call TITLE, POST SETUP HOME DIRECTORY)
		rm -rfv ~/Desktop
		rm -rfv ~/Music
		rm -rfv ~/Public
		rm -rfv ~/Videos
		rm -rfv ~/Documents
		rm -rfv ~/Pictures
		rm -rfv ~/Templates
		rm -rfv ~/examples.desktop
		$(call INFO,home directory: $$(ls -l $(HOME)))

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

data: ##Setup i3 background, scripts and dotfiles
	$(call TITLE, CREATE i3 DIR)
		mkdir -p ~/.i3

	$(call TITLE, COPY BACKGROUND)
		cp -rv $(BACKGROUND) ~/.i3

	$(call TITLE, COPY DOTFILES)
		for fpath in $(DOTFILES)/*; do
			newPath=$$(echo $$fpath | sed -e 's/^.*\///g' -e 's/_|_/\//g' -e "s/~/\/home\/${USER}/g")
			mkdir -p $$(dirname $$newPath)
			cp $$fpath $$newPath
			sed -i -e "s/USER/${USER}/g" -e "s/EMAIL/${EMAIL}/g" $$newPath
			printf "%-35s -> %s\n" $$(basename $$fpath) $$newPath
		done

#=====================================================================
### Setup your own vcs ####################
#=====================================================================

vcs: vcs-setup vcs-jetbrains

vcs-setup: ##Create vcs directory and clone repos
	$(call TITLE, POST SETUP VCS)
		$(call MKDIR,$(VCS))
		$(call GIT_CLONE,https://github.com/$(AUTHOR)/mylinux.git,$(VCS)/mylinux)
		$(call GIT_CLONE,https://github.com/$(AUTHOR)/jetbrains.git,$(VCS)/jetbrains)

vcs-jetbrains: ##Install my repositories
	$(call TITLE, POST SETUP JETBRAINS)
		cd $(VCS)/jetbrains; make install || echo "Jetbrains installation failed..."

#=====================================================================
### Finish procedure #################################################
#=====================================================================

finish: ##Finish procedure (user permissions, rebooting)
	$(call TITLE, POST SETUP CHOWN HOME DIR)
		chown -R $(USER) $(HOME)
		$(call INFO,folder \"$(HOME)\" now belongs to \"$(USER)\")
		chmod 777 $(BIN) -R
		$(call INFO,folder \"$(BIN)\" now belongs to \"$(USER)\")

	$(call TITLE, RESTARTING)
		read -p "Reboot the sistem? (y/n): " -n 1 -r
		echo
		if [[ $$REPLY =~ ^[Yy] ]]; then
			$(call ALERT,rebooting the sistem...)
			reboot
		else
			echo
			$(call ALERT,you should reboot the sistem ASAP...)
		fi
