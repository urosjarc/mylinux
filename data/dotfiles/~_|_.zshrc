#Global zsh path
export ZSH=/home/USER/.oh-my-zsh

#ZSH settings
ZSH_THEME="avit"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(git zsh-syntax-highlighting)

bindkey -v
bindkey "^R" history-incremental-search-backward

#Plugin shell
source $ZSH/oh-my-zsh.sh

#BASH
[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

#My settings
printf '\n ---> WELLCOME (⌐■_■) \n'
