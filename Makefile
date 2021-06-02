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

#==================================================================
### Running whole installation procedure ##########################
#==================================================================

run-select: ##Select which targets you want to run
	$(MAKE) $$(whiptail --title "Select target to install" --checklist "Choose:" 20 30 15 \
		"setup" "" on \
		"install" "" on \
		"install-apps" "" on \
		"update" "" off \
		"post-install" "" on \
		"post-setup" "" on \
		"data" "" on \
		"vcs" "" on \
		"finish" "" on \
		3>&1 1>&2 2>&3)

run: setup install install-apps post-install post-setup data vcs finish ##Run default installation set

#=====================================================================
### Setup requirements for installation procedures ###################
#=====================================================================

setup: setup-apt setup-dirs

setup-apt: ##Add all repositories to apt
	$(call TITLE, SETUP APT REPOS)
		add-apt-repository -y ppa:nilarimogard/webupd8                                              # Audacity
		add-apt-repository -y ppa:maarten-fonville/android-studio                                   # Android studio
		add-apt-repository -y ppa:peek-developers/stable                                            # Peep (gif screen recorder)

	$(call TITLE, SETUP NEO4J SOURCES)
		wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
		echo 'deb https://debian.neo4j.com stable latest' | sudo tee /etc/apt/sources.list.d/neo4j.list

	$(call TITLE, UPDATE APT)
		apt-get update

setup-dirs: ##Create folder for tar apps to install in
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
### Installation for package managers ######
#===========================================

install: install-drivers install-apt install-snap install-npm install-pip3 install-gem

install-drivers:
	$(call TITLE, INSTALL DRIVERS)
		ubuntu-drivers autoinstall

install-apt:
	$(call TITLE, INSTALL APT PACKAGES)
		$(call INSTALL,apt-get -y install,apt)

install-snap:
	$(call TITLE, INSTALL SNAP PACKAGES)
		$(call INSTALL_LOOP,snap install --classic,snap)

install-npm:
	$(call TITLE, INSTALL NPM PACKAGES)
		$(call INSTALL,npm install -g,npm)

install-pip3:
	$(call TITLE, INSTALL PIP3 PACKAGES)
		$(call INSTALL,pip3 install,pip3)

install-gem:
	$(call TITLE, INSTALL GEM PACKAGES)
		$(call INSTALL,gem install,gem)

#===========================================
### Installation for applications ##########
#===========================================

install-apps: install-apps-pycharm install-apps-intellij install-apps-clion install-apps-webstorm install-apps-chrome install-apps-qutebrowser

install-apps-pycharm:
	$(call TITLE, INSTALL PYCHARM)
		$(call WGET_TAR,pycharm.tar.gz,https://download.jetbrains.com/python/pycharm-community-$(PYCHARM).tar.gz)
		$(call LINK_BIN,$(APPS)/pycharm-community-$(PYCHARM)/bin/pycharm.sh,pycharm)

install-apps-intellij:
	$(call TITLE, INSTALL INTELLIJ)
		$(call WGET_TAR,intellij.tar.gz,https://download.jetbrains.com/idea/ideaIC-$(IDEA).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/idea-IC-.*/bin/idea.sh'),idea)

install-apps-clion:
	$(call TITLE, INSTALL CLION)
		$(call WGET_TAR,clion.tar.gz,https://download.jetbrains.com/cpp/CLion-$(CLION).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/clion.*/bin/clion.sh'),clion)

install-apps-webstorm:
	$(call TITLE, INSTALL WEBSTORM)
		$(call WGET_TAR,webstorm.tar.gz,https://download.jetbrains.com/webstorm/WebStorm-$(WEBSTORM).tar.gz)
		$(call LINK_BIN,$$(find $(APPS) -regex '.*\/WebStorm.*/bin/webstorm.sh'),webstorm)

install-apps-chrome:
	$(call TITLE, INSTALL CHROME)
		$(call WGET_DEB,google-chrome-stable_current_amd64.deb,https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb)

install-apps-qutebrowser:
	$(call TITLE, INSTALL QUTEBROWSER)
		$(call GIT_CLONE,https://github.com/qutebrowser/qutebrowser.git,$(APPS)/qb)
		cd $(APPS)/qb && python3 scripts/mkvenv.py
		rm -f $(APPS)/qb/qutebrowser.sh
		echo -e "#!/bin/bash\n$(APPS)/qb/.venv/bin/python3 -m qutebrowser" > $(APPS)/qb/qutebrowser.sh
		chmod 777 $(APPS)/qb/qutebrowser.sh
		$(call LINK_BIN,$(APPS)/qb/qutebrowser.sh,qutebrowser)


install-apps-android:
	$(call TITLE, INSTALL ANDROID)
		$(call INSTALL,apt-get -y install,apt-android)
		echo
		$(call LINK_BIN,/opt/android-studio/bin/studio.sh,android-studio)


#============================================
### Post installation procedures ############
#============================================

post-install: ##Install zsh, fonts, jupyter
	$(call TITLE, POST APT AUTOREMOVE)
		apt autoremove

	$(call TITLE, POST INSTALL PROFILERS)
		apt install -y "linux-tools-$(KERNEL)" valgrind

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

	$(call TITLE, POST INSTALL JUPYTER)
		jupyter contrib nbextension install --user
		jupyter nbextensions_configurator enable --user

#====================================================
### Post installation setup procedures ##############
#====================================================

post-setup: ##Setup inotify, alternatives, vcs, clean home directory
	$(call TITLE, POST SETUP PROFILER)
		sh -c 'echo 1 >/proc/sys/kernel/perf_event_paranoid'
		sh -c 'echo 0 >/proc/sys/kernel/kptr_restrict'
		sh -c 'echo kernel.perf_event_paranoid=1 >> /etc/sysctl.d/99-perf.conf'
		sh -c 'echo kernel.kptr_restrict=0 >> /etc/sysctl.d/99-perf.conf'
		sh -c 'sysctl --system'

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

data: ##Setup i3 background, layouts, scripts and dotfiles
	$(call TITLE, COPY BACKGROUND)
		cp -rv $(BACKGROUND) ~/.i3

	$(call TITLE, COPY LAYOUTS)
		cp -rv $(LAYOUTS) ~/.i3

	$(call TITLE, COPY BIN)
		cp -rv $(SCRIPTS)/* $(BIN)

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
