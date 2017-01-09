#!/usr/bin/env zsh
# Based off Pure <https://github.com/sindresorhus/pure>

_strlen() { echo ${#${(S%%)1//$~%([BSUbfksu]|([FB]|){*})/}}; }

# fastest possible way to check if repo is dirty
prompt_git_dirty() {
    is-callable git || return

    # disable auth prompting on git 2.3+
    GIT_TERMINAL_PROMPT=0

    # check if we're in a git repo
    [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]] || return
    # check if it's dirty
    command test -n "$(git status --porcelain --ignore-submodules -unormal)" || return

    echo -n "%F{red}[+]"
    local r=$(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null)
    local l=$(command git rev-list --left-only --count HEAD...@'{u}' 2>/dev/null)

    (( ${r:-0} > 0 )) && echo -n " %F{green}${r}⇣"
    (( ${l:-0} > 0 )) && echo -n " %F{yellow}${l}⇡"
    echo -n '%f'
}

## Hooks ###############################
prompt_hook_precmd() {
    print -Pn '\e]0;%~\a' # full path in the title
    vcs_info # get git info
    # Newline before prompt, excpet on init
    [[ -n "$_DONE" ]] && print ""; _DONE=1
}

## Initialization ######################
prompt_init() {
    # prevent percentage showing up if output doesn't end with a newline
    export PROMPT_EOL_MARK=''

    prompt_opts=(cr subst percent)

    setopt PROMPTSUBST
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    add-zsh-hook precmd prompt_hook_precmd
    # Updates cursor shape and prompt symbol based on vim mode
    zle-keymap-select() {
        case $KEYMAP in
            vicmd)      PROMPT_SYMBOL=$N_MODE ;;
            main|viins) PROMPT_SYMBOL=$I_MODE ;;
        esac
        zle reset-prompt
        zle -R
    }
    zle -N zle-keymap-select
    zle -A zle-keymap-select zle-line-init

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' use-simple true
    zstyle ':vcs_info:*' max-exports 2
    zstyle ':vcs_info:git*' formats ':%b'
    zstyle ':vcs_info:git*' actionformats ':%b (%a)'

    # show username@host if logged in through SSH
    prompt_username=
    is-ssh && prompt_username='%F{magenta}%n%F{244}@%m '

    ## Vim cursors
    if [[ "$SSH_CONNECTION" ]]; then
        N_MODE="%F{red}### "
        I_MODE="%(?.%F{magenta}.%F{red})λ "
    else
        N_MODE="%F{magenta}## "
        I_MODE="%(?.%F{blue}.%F{red})λ "
    fi

    RPROMPT='%F{cyan}${vcs_info_msg_0_}$(prompt_git_dirty)%f'
    PROMPT='${prompt_username}%F{cyan}%~ %f${PROMPT_SYMBOL:-$ }%f'
}

prompt_init "$@"
