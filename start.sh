printS () { printf "\n\n... $1 ...\n\n"; read -p "Press enter to continue"; }
open () { xdg-open $1 > output.log 2>&1 & }

printS "Install make"
sudo apt install -y make

printS "Setup background images"
nautilus /usr/share/backgrounds/ ./data/background/

printS "Setup apps versions"
open config/variables 
open https://nodejs.org 
open https://www.jetbrains.com/pycharm/download/#section=linux
open https://www.jetbrains.com/idea/download/#section=linux
open https://www.jetbrains.com/webstorm/download/#section=linux
open https://www.jetbrains.com/clion/download/#section=linux 
open https://github.com/SSNikolaevich/DejaVuSansCode/releases
