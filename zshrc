autoload -Uz compinit promptinit
compinit
promptinit
prompt redhat

bindkey -v

HISTFILE=~/.zshhist
HISTSIZE=1000
SAVEHIST=1000

setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NOTIFY
setopt COMPLETE_ALIASES

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion::complete:*' gain-privileges 1

if (( $+commands[exa] ));
then
	alias ls='exa -F'
	alias ll='exa -F -l --header'
	alias la='exa -F -l -a --header'
fi

if (( $+commands[git] ));
then
	alias gl='git pull'
	alias gp='git push'
	alias gst='git status'
fi
