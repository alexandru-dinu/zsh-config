# add plugin-dirs to fpath
for p in $plugins; do
    fpath=($ZDOTDIR/plugins/$p $fpath)
done

zmodload zsh/complist
zmodload zsh/zle
autoload -Uz add-zsh-hook
autoload -Uz colors && colors
autoload -Uz compinit && compinit -u -C -d "$XDG_DATA_HOME/zsh/zcompdump"
autoload -U +X bashcompinit && bashcompinit

# use the default ls color theme
if [[ -z "$LS_COLORS" ]]; then
    (( $+commands[dircolors] )) && eval "$(dircolors -b)"
fi

unsetopt menu_complete      # do not autoselect the first completion entry
unsetopt flowcontrol        # disable start/stop flow control (^S/^Q)
setopt auto_menu            # show completion menu on successive tab press
setopt complete_in_word     # allow completion from within a word
setopt always_to_end        # move cursor to the end of the word on completion
setopt interactive_comments # allow comments
setopt auto_pushd           # make cd push the old dir onto the stack
setopt pushd_ignore_dups    # don't push multiple copies of the same dir
setopt pushdminus           # exchange the meaning of +/- when used with a number to specify a dir in the stack
setopt prompt_subst         # enable parameter expansion

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$XDG_DATA_HOME/zsh/zcompcache"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

_comp_options+=(globdots)

# enable correction
setopt correct_all
alias cp='nocorrect cp'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias sudo='nocorrect sudo'

## history
HISTFILE="$XDG_DATA_HOME/zsh/history"
HISTSIZE=1000000
SAVEHIST=1000000

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # append new entries incrementally as soon as they are entered

# keybindings
bindkey -M menuselect '^[[Z' reverse-menu-complete

# vi-mode
bindkey -v
export KEYTIMEOUT=1

bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward
bindkey '^?' backward-delete-char

# use <C-g> to edit current command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^g' edit-command-line
bindkey -M vicmd '^g' edit-command-line

function zle-line-init zle-keymap-select {
    ZSH_PROMPT_ARROW="${${KEYMAP/vicmd/❮}/(main|viins)/❯}"
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# copy selection to clipboard
function vi-yank-xclip {
    zle vi-yank
    echo "$CUTBUFFER" | xsel --clipboard
}
zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip

# async git info
source $ZDOTDIR/async.zsh
async_init
source $ZDOTDIR/git.zsh

# source plugins defined in .zshrc
for p in $plugins; do
    source $ZDOTDIR/plugins/$p/$p.plugin.zsh
done

# source theme
source $ZDOTDIR/theme.zsh

# nicer defaults
alias ls='ls --color=tty -F'
alias ll='ls -lah'
alias diff='diff --color'
alias grep='grep --color=auto --exclude-dir=.git'
