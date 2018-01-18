#!/usr/bin/env bash

function print() {
	echo
	echo '╔═══════════════════════════════════════════════════════════════╡'
	echo "║ ($OSTYPE): " $1
	echo '╚═══════════════════════════════════════════════════════════════╡'
	echo
}

function testing() {
	echo '┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫'
	echo "┃ TESTING:" $1
	echo '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫'
	echo
}

print "Update apt"
sudo apt-get update

print "Install slack"
sudo apt-get install libindicator7 libappindicator1 slack-desktop

print "Install ctop (container top)"
sudo wget https://github.com/bcicen/ctop/releases/download/v0.7/ctop-0.7-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

print "Install docker comunity edition"
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce

print "Docker permissions"
sudo groupadd docker
sudo usermod -aG docker $USER

print "Testing docker"
sudo docker run hello-world

print "Testing docker-compose"
docker-compose -v

print "Adding certificates for mab"
# -> https://ca.celtra.com/
# Zlovdaj PEM certifikat za test
# chrome -> settings -> advance -> manage certificates -> Authorities -> Import -> pem cert...

print "Setup Celtra vcs"
mkdir -p ~/vcs-celtra
pushd ~/vcs-celtra;

	git clone https://github.com/celtra/mab
	pushd mab;
		echo "https://github.com/celtra/mab/wiki/Docker-workflow#from-zero-to-running-adcreator-in-10-steps"
	popd;

popd;

