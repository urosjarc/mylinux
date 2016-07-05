#Global zsh path
export ZSH=/home/urosjarc/.oh-my-zsh

#ZSH settings
ZSH_THEME="avit"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(git)

bindkey -v
bindkey "^R" history-incremental-search-backward

#Plugin shell
source $ZSH/oh-my-zsh.sh

#My settings
printf '\n ---> WELLCOME UROS :)\n'
