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

print "Install docker compose"
sudo apt-get install docker-compose -y

print "Testing docker"
sudo docker run hello-world

print "Testing docker-compose"
docker-compose -v

print "Setup Celtra vcs"

mkdir -p ~/vcs-celtra
pushd ~/vcs-celtra;

	git clone https://github.com/celtra/mab
	pushd mab;
		ls
	popd;

popd;

