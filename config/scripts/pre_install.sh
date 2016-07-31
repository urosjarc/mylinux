wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb http://debian.neo4j.org/repo stable/' > /tmp/neo4j.list
sudo mv /tmp/neo4j.list /etc/apt/sources.list.d

curl --silent --location https://deb.nodesource.com/setup_6.x | sudo bash -

sudo add-apt-repository ppa:cwchien/gradle -y
sudo add-apt-repository ppa:webupd8team/java -y
sudo add-apt-repository ppa:eugenesan/ppa -y

sudo apt-get update

