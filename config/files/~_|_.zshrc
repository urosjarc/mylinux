#Global zsh path
export ZSH=/home/urosjarc/.oh-my-zsh

#ZSH settings
ZSH_THEME="avit"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(git zsh-syntax-highlighting)

bindkey -v
bindkey "^R" history-incremental-search-backward

#Plugin shell
source $ZSH/oh-my-zsh.sh

#NVM support
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

#BASH
[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

#My settings
printf '\n ---> WELLCOME UROS :)\n'
{

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa_github
    ssh-add ~/.ssh/id_rsa_bitbucket

} &> /dev/null
