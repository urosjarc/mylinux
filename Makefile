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
		"finish" "" on \
		3>&1 1>&2 2>&3)

run-min: setup install             post-install post-setup data vcs finish ##Run minimalistic installation set
run-all: setup install install-opt post-install post-setup data vcs finish ##Run whole installation set.

#=====================================================================
### Setup requirements for installation procedures ###################
#=====================================================================

setup: setup-apt setup-dirs

setup-apt: ##Add all repositories to apt.
	$(call TITLE, SETUP APT REPOS)
		add-apt-repository -y ppa:danielrichter2007/grub-customizer                                 # Grub customizer
		add-apt-repository -y ppa:yannubuntu/boot-repair                                            # Boot repair
		add-apt-repository -y ppa:nilarimogard/webupd8                                              # Audacity, woeusb
		add-apt-repository -y ppa:maarten-fonville/android-studio                                   # Android studio
		add-apt-repository -y "deb http://archive.canonical.com $$(lsb_release -sc) partner"        # Flash plugins (firefox, chrome)

	$(call TITLE, SETUP NODE SOURCES)
		wget -O - https://deb.nodesource.com/setup_$(NODE).x | sudo -E bash -

	$(call TITLE, UPDATE APT)
		apt-get update

setup-dirs:
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

install: install-apt install-npm install-pip3 install-gem install-apps-pycharm install-apps-intellij install-apps-clion

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

install-apps-pycharm:
	$(call TITLE, INSTALL PYCHARM)
		$(call WGET_APP,pycharm.tar.gz,https://download.jetbrains.com/python/pycharm-community-$(PYCHARM).tar.gz)
		$(call LINK_BIN,$(APPS)/pycharm-community-$(PYCHARM)/bin/pycharm.sh,pycharm)

install-apps-intellij:
	$(call TITLE, INSTALL INTELLIJ)
		$(call WGET_APP,intellij.tar.gz,https://download.jetbrains.com/idea/ideaIC-$(IDEA).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/idea-IC-.*/bin/idea.sh'),idea)

install-apps-clion:
	$(call TITLE, INSTALL CLION)
		$(call WGET_APP,clion.tar.gz,https://download.jetbrains.com/cpp/CLion-$(CLION).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/clion.*/bin/clion.sh'),clion)


install-opt: install-apt-optional install-apps-webstorm

install-apt-optional:
	$(call TITLE, INSTALL APT PACKAGES)
		$(call INSTALL,apt-get -y install,apt-optional)

install-apps-android:
	$(call TITLE, INSTALL ANDROID)
		$(call INSTALL,apt-get -y install,apt-android)
		echo
		$(call LINK_BIN,/opt/android-studio/bin/studio.sh,android-studio)

install-apps-webstorm:
	$(call TITLE, INSTALL WEBSTORM)
		$(call WGET_APP,webstorm.tar.gz,https://download.jetbrains.com/webstorm/WebStorm-$(WEBSTORM).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/WebStorm.*/bin/webstorm.sh'),webstorm)

install-apps-simplicity:
	$(call TITLE, INSTALL SIMPLICITY)
		$(call WGET_APP,simplicity.tar.gz,https://www.silabs.com/documents/login/software/SimplicityStudio-$(SIMPLICITY).tgz)
		echo -e 'cd ${APPS}/SimplicityStudio_${SIMPLICITY}/ && ./run_studio.sh' > ${BIN}/simplicity
		cat ${BIN}/simplicity

#============================================
### Post installation procedures ############
#============================================

post-install: ##Install zsh, i3, heroku, fonts, jupyter
	$(call TITLE, POST INSTALL ZSH TOOLS)
		wget -O- https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
		echo
		$(call GIT_CLONE,https://github.com/zsh-users/zsh-syntax-highlighting.git,~/.oh-my-zsh/plugins/zsh-syntax-highlighting)

	$(call TITLE, POST INSTALL I3 TOOLS)
		$(call GIT_CLONE,https://github.com/guimeira/i3lock-fancy-multimonitor.git,~/.i3/i3lock-fancy-multimonitor)
		$(call INFO,$$(chmod -v +x ~/.i3/i3lock-fancy-multimonitor/lock))

	$(call TITLE, POST INSTALL HEROKU)
		wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh

	$(call TITLE, POST INSTALL CODE FONTS)
		$(call WGET_APP,dejavu-code-ttf,https://github.com/SSNikolaevich/DejaVuSansCode/releases/download/v$(CODE_FONTS)/dejavu-code-ttf-$(CODE_FONTS).tar.bz2)
		cp -v $(APPS)/dejavu-code-ttf-$(CODE_FONTS)/ttf/* /usr/local/share/fonts
		fc-cache -f
		echo
		$(call INFO,installed fonts [DejaVuSansCode])
		fc-list | grep "DejaVuSansCode"

	$(call TITLE, POST INSTALL JUPYTER)
		jupyter contrib nbextension install --user
		jupyter nbextensions_configurator enable --user

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
		$(call INFO,home directory: $$(ls -l $(HOME)))

	$(call TITLE, POST SETUP ALTERNATIVES)
		update-alternatives --config x-www-browser
		update-alternatives --config x-terminal-emulator

	$(call TITLE, POST SETUP SHELL)
		$(call INFO,$$(grep $(USER) /etc/passwd | sed -e 's/.*,,,://g'))
		usermod --shell $$(which zsh) $(USER)
		$(call INFO,$$(grep $(USER) /etc/passwd | sed -e 's/.*,,,://g'))

	$(call TITLE, POST SETUP WIRESHARK)
		sudo adduser $(USER) wireshark

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
			mkdir -p $$(dirname $$newPath)
			cp $$fpath $$newPath
			printf "%-35s -> %s\n" $$(basename $$fpath) $$newPath
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
### Finish procedure #################################################
#=====================================================================

finish: ##Finish procedure (user permissions, rebooting)
	$(call TITLE, POST SETUP CHOWN HOME DIR)
		chown -R $(USER) $(HOME)
		$(call INFO,folder \"$(HOME)\" now belongs to \"$(USER)\")

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

