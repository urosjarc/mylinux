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


print "Install charles proxy"
wget -q -O - https://www.charlesproxy.com/packages/apt/PublicKey | sudo apt-key add -
sudo sh -c 'echo deb https://www.charlesproxy.com/packages/apt/ charles-proxy main > /etc/apt/sources.list.d/charles.list'
sudo apt-get update
sudo apt-get install charles-proxy


print "Install docker comunity edition"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


sudo apt-get update
sudo apt-get install docker-ce -y

print "Docker permissions"
sudo groupadd docker
sudo usermod -aG docker $USER

print "Install docker compose"
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


print "Testing docker"
sudo docker run hello-world


print "Testing docker-compose"
docker-compose -v

