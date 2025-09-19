ZSH_COLOR_MAIN="cyan"
ZSH_COLOR_INFO="bright-black"
ZSH_COLOR_DIRTY="red"

_git_info () {
    # no info to show (e.g. not inside a repo)
    [[ -z "$_GIT_INFO" ]] && return

    # parse info into a map
    declare -A info=( ${(@s: :)_GIT_INFO} )
    declare -A repr

    repr[branch]="%F{$ZSH_COLOR_INFO}$info[branch]%f"

    [[ $info[dirty] = "true" ]] && repr[dirty]="%F{$ZSH_COLOR_DIRTY}*%f"
    [[ $info[ahead] != "0" ]] && repr[ahead]="%F{$ZSH_COLOR_DIRTY}$info[ahead]↑%f"
    [[ $info[stash] != "0" ]] && repr[stash]="%F{$ZSH_COLOR_DIRTY}$info[stash]↴%f"

    local sepl="%F{$ZSH_COLOR_INFO}(%f"
    local sepr="%F{$ZSH_COLOR_INFO})%f"
    local symb=$( () { print -l "$*" } $repr[dirty] $repr[stash] $repr[ahead] )

    local out=$repr[branch]
    [[ -n $symb ]] && out+=$sepl$symb$sepr

    echo "$out "
}

_conda_info () {
    # only show info on non-base envs
    if [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
        echo "%F{$ZSH_COLOR_INFO}conda:$CONDA_DEFAULT_ENV%f "
    fi
}

_venv_info () {
    # when default prompt info is disabled, use ours
    if [[ -n "$VIRTUAL_ENV_DISABLE_PROMPT" && -n "$VIRTUAL_ENV" ]]; then
        # delete longest match of */ from venv (i.e. keep the basename)
        echo "%F{$ZSH_COLOR_INFO}venv:${VIRTUAL_ENV##*/}%f "
    fi
}

PROMPT=$'\n'
PROMPT+='%F{$ZSH_COLOR_MAIN}%3~%f '
PROMPT+='$(_git_info)'
PROMPT+='$(_conda_info)'
PROMPT+='$(_venv_info)'
PROMPT+=$'\n'
PROMPT+='%(?:%F{$ZSH_COLOR_MAIN}:%F{$ZSH_COLOR_DIRTY})${ZSH_PROMPT_ARROW:-❯}%f '
