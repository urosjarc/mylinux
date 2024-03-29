printS () { printf "\n\n... $1 ...\n\n"; read -p "Press enter to continue"; }
open () { xdg-open $1 > output.log 2>&1 & }

printS "Install make"
sudo apt update
sudo apt install -y make

printS "Setup background images"
open /usr/share/backgrounds/
open ./data/background/


printS "Setup user info and versions"
open config/variables
open https://github.com/SSNikolaevich/DejaVuSansCode/releases
