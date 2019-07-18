include config/utils
include config/variables
include config/functions

#============================
### setup ########
#============================

setup-apt:
	$(call INFO, SETUP APT REPOS)
		add-apt-repository ppa:yannubuntu/boot-repair 		-y				# Boot repair
		add-apt-repository ppa:nilarimogard/webupd8		-y				# Audacity, woeusb
		add-apt-repository ppa:maarten-fonville/android-studio  -y				# Android studio
		add-apt-repository "deb http://archive.canonical.com/ $(shell lsb_release -sc) partner"	# Flash plugins (firefox, chrome)

	$(call INFO, SETUP neo4j SOURCES)
		wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
		echo 'deb http://debian.neo4j.org/repo stable/' > /tmp/neo4j.list
		mv /tmp/neo4j.list /etc/apt/sources.list.d

setup-nvm:
	$(call INFO, INSTALL NVM)
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$(NVM)/install.sh | bash
		export NVM_DIR="$HOME/.nvm"
		[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
		nvm install --lts

	$(call INFO, SETUP EXE LINKS)
		ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/node" "/usr/local/bin/node"
		ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npm" "/usr/local/bin/npm"

#============================
### update ########
#============================

update-apt:
	$(call INFO, UPDATE APT)
		apt-get update

update-npm:
	$(call INFO, UPDATE NPM)
		npm install -g npm

update-gem:
	$(call INFO, UPDATE GEM)
		gem update

update-pip3:
	$(call INFO, UPDATE PIP3)
		pip3 install --upgrade setuptools pip

#============================
### install ########
#============================

install-apt:
	$(call PRINT, INSTALL APT PACKAGES)
		apt-get install $(grep -vE "^\s*#" $(PACKAGES)/apt | tr "\n" " ")

install-npm:
	$(call PRINT, INSTALL NPM PACKAGES)
		npm install -g $(grep -vE "^\s*#" $(PACKAGES)/npm | tr "\n" " ")

install-pip3:
	$(call PRINT, INSTALL PIP3 PACKAGES)
		pip3 install $(grep -vE "^\s*#" $(PACKAGES)/pip | tr "\n" " ")

install-gem:
	$(call PRINT, INSTALL GEM PACKAGES)
		gem install $(grep -vE "^\s*#" $(PACKAGES)/gem | tr "\n" " ")





































