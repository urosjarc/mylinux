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

#SHORTCUTS
alias adjack="docker start adjack -ai"
alias dc='docker-compose'
alias dc-logs='dc logs --tail=100 -f'
alias dc-stats='dc ps | grep Up | cut -d" " -f1 | tr "\\n" " " | xargs docker stats'
alias dc-build='dc down && docker volume rm mab_build-artifacts || true && dc build'
alias dc-up='dc up -d ads cache compiler dev-proxy dev-storage deviceinfo garbage-collector geo geoip hub rule-evaluator thumbnail-updater tracker video weather'
