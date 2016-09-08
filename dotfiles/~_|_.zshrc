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
{
    export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa_github
    ssh-add ~/.ssh/id_rsa_bitbucket

    source /usr/local/bin/virtualenvwrapper.sh

} &> /dev/null
