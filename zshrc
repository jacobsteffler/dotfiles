autoload -Uz compinit
compinit

case $TERM in
    xterm*)
        precmd() { print -Pn "\e]0;Terminal [%~]\a" }
        ;;
esac

if [[ -v SSH_CONNECTION ]];
then
    PS1='%B(%m) %2~ %(?.%F{green}.%F{red})%(!.#.$)>%f%b '
else
    PS1='%B%2~ %(?.%F{green}.%F{red})%(!.#.$)>%f%b '
fi

bindkey -v

HISTFILE=~/.zshhist
HISTSIZE=1000
SAVEHIST=1000

setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NOTIFY
setopt COMPLETE_ALIASES

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion::complete:*' gain-privileges 1

if (( $+commands[sudo] ));
then
    alias se='sudo -e'
fi

if (( $+commands[exa] ));
then
    alias ls='exa -F'
    alias ll='exa -F -l --header'
    alias lt='exa -F -l --header --tree'
    alias la='exa -F -l -a --header'
fi

if (( $+commands[git] ));
then
    alias gl='git pull'
    alias gp='git push'
    alias gst='git status'
    alias glog='git log --oneline --decorate --graph'
fi

if (( $+commands[xdg-open] ));
then
    alias xo='xdg-open'
fi

if (( $+commands[wordgrinder] ));
then
    alias wg='wordgrinder'
fi

if (( $+commands[tmux] ));
then
    alias umux='tmux detach -E false'

    if [[ -v SSH_CONNECTION ]] && [[ ! -v TMUX ]];
    then
        tmux attach-session -t ssh_tmux || \
            tmux new-session -s ssh_tmux && \
            exit
    fi
fi
