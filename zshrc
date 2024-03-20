autoload -Uz compinit
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
autoload -Uz edit-command-line

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -v
bindkey "^[[A" up-line-or-beginning-search      # up
bindkey "^[[B" down-line-or-beginning-search    # down
bindkey "^[[1;5D" backward-word                 # ctrl-left
bindkey "^[[1;5C" forward-word                  # ctrl-right
bindkey "^[[3;5~" kill-word                     # ctrl-delete
bindkey "^H" backward-kill-word                 # ctrl-backspace
bindkey "^[[3~" delete-char                     # delete
bindkey "^[[H" beginning-of-line                # home
bindkey "^[[F" end-of-line                      # end

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
    PS1='%B(%m) %40>...>%2~%>> %(?.%F{green}.%F{red})%(!.#.$)>%f%b '
else
    PS1='%B%40>...>%2~%>> %(?.%F{green}.%F{red})%(!.#.$)>%f%b '
fi

if [[ -f ~/.zshpath ]];
then
    source ~/.zshpath
fi

if (( $+commands[keychain] ));
then
    eval $(keychain --eval --noask --quiet --timeout 180)
fi

if (( $+commands[eza] ));
then
    alias ls='eza -F'
    alias ll='eza -F -l --header --group'
    alias lt='eza -F -l --header --tree --group'
    alias la='eza -F -l -a --header --group'
fi

if (( $+commands[git] ));
then
    alias gl='git pull'
    alias gp='git push'
    alias gst='git status'
    alias gf='git fetch -v'
    alias glog='git log --oneline --decorate --graph'
fi

if (( $+commands[xdg-open] ));
then
    alias xo='xdg-open'
fi

if (( $+commands[bat] ));
then
    alias cat='bat'
fi

if (( $+commands[tmux] ));
then

    # If we're in a zsh session, but not in tmux
    if [[ -f ~/.zshtmux  ]] && [[ ! -v TMUX ]];
    then

        # Connect to or create the "zsh_tmux"
        # session; close the session if tmux
        # exits with a successful return code
        tmux attach-session -t zsh_tmux || \
            tmux new-session -s zsh_tmux && \
            exit
    fi

    # Use this command to close tmux with a
    # failure return code, to return to a normal
    # shell without closing the session
    alias umux='tmux detach -E false'
fi
