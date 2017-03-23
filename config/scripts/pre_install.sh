echo '\n...SET SOURCES...\n'

wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb http://debian.neo4j.org/repo stable/' > /tmp/neo4j.list
sudo mv /tmp/neo4j.list /etc/apt/sources.list.d

echo '\n...SET KEYS...\n'

sudo add-apt-repository ppa:yannubuntu/boot-repair	-y
sudo add-apt-repository ppa:cwchien/gradle              -y
sudo add-apt-repository ppa:indicator-brightness/ppa    -y
sudo add-apt-repository ppa:webupd8team/java            -y
sudo add-apt-repository ppa:nilarimogard/webupd8        -y
sudo add-apt-repository ppa:phablet-team/tools          -y

echo '\n...UPGRADE MANAGERS...\n'

sudo apt-get update
pip install --upgrade pip

echo '\n...INSTALL NVM & NPM...\n'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
npm update npm -g
npm install yo -g
