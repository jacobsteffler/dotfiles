autoload -Uz compinit
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
autoload -Uz edit-command-line

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line

bindkey -v
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^xe" edit-command-line
bindkey "^x^e" edit-command-line

HISTFILE=~/.zshhist
HISTSIZE=1000
SAVEHIST=1000

setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NOTIFY
setopt COMPLETE_ALIASES

compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion::complete:*' gain-privileges 1

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

if [[ $TERM == 'xterm-kitty' ]];
then
    alias icat='kitty +kitten icat'
fi
