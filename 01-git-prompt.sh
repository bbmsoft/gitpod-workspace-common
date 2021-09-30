#!/bin/bash

# in order for this to work, you must do the following once:
# curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh

CRAB='$([ -f "./Cargo.toml" ] && echo " 🦀")'
ROCKET='$([ -f "./Rocket.toml" ] && echo " 🚀")'
COFFEE='$(([ -f "./pom.xml" ] || [ -f "./build.gradle" ] || [ -f "./gradlew" ]) && echo " ☕")'
WEB='$(([ -f "./package.json" ] || [ -f "./webpack.config.js" ]) && echo " 🕸 ")'
GOPHER='$([ -f "./go.mod" ] && echo " ʕ◔ϖ◔ʔ")'

CYAN="\[$(tput setaf 6)\]"
LCYAN="\[$(tput setaf 14)\]"
MAGENTA="\[$(tput setaf 5)\]"
GRAY="\[$(tput setaf 7)\]"
DRED="\[$(tput setaf 1)\]"
RED="\[$(tput setaf 1)\]"
RESET="\[$(tput sgr0)\]"
DIM="\[$(tput dim)\]"
BOLD="\[$(tput bold)\]"

if [ -f "$HOME/.git-prompt.sh" ]; then
    source "$HOME/.git-prompt.sh"
fi

export GIT_PS1_SHOWDIRTYSTATE=1          # '*'=unstaged, '+'=staged
export GIT_PS1_SHOWSTASHSTATE=1          # '$'=stashed
export GIT_PS1_SHOWUNTRACKEDFILES=1      # '%'=untracked
export GIT_PS1_STATESEPARATOR=''         # No space between branch and index status
export GIT_PS1_DESCRIBE_STYLE="describe" # detached HEAD style:
export GIT_PS1_SHOWUPSTREAM=auto

# Check if we support colours
__colour_enabled() {
    local -i colors=$(tput colors 2>/dev/null)
    [[ $? -eq 0 ]] && [[ $colors -gt 2 ]]
}
unset __colourise_prompt && __colour_enabled && __colourise_prompt=1

__set_bash_prompt() {
    local exit="$?" # Save the exit status of the last command

    # PS1 is made from $PreGitPS1 + <git-status> + $PostGitPS1
    local PreGitPS1=""
    local PostGitPS1=""

    if [[ $__colourise_prompt ]]; then
        export GIT_PS1_SHOWCOLORHINTS=1

        # No username and bright colour if root
        if [[ ${EUID} == 0 ]]; then
            PreGitPS1+="${RED}${BOLD}\u${RESET}@\h "
        else
            PreGitPS1+="${CYAN}\u${RESET} "
        fi

        PreGitPS1+="\W"
    else # No colour
        # Sets prompt like: ravi@boxy:~/prj/sample_app
        unset GIT_PS1_SHOWCOLORHINTS
        PreGitPS1="\u \W"
    fi

    PreGitPS1+="$COFFEE"
    PreGitPS1+="$CRAB"
    PreGitPS1+="$GOPHER"
    PreGitPS1+="$ROCKET"
    PreGitPS1+="$WEB"

    # Now build the part after git's status

    # Highlight non-standard exit codes
    if [[ $exit != 0 ]]; then
        PostGitPS1+=" [${RED}$exit${RESET}]"
    fi

    # Change colour of prompt if root
    if [[ ${EUID} == 0 ]]; then
        PostGitPS1+=" ${DIM}${DRED}>${RESET}${DRED}>${RED}>${RESET} "
    else
        PostGitPS1+=" ${DIM}${CYAN}>${RESET}${CYAN}>${LCYAN}>${RESET} "
    fi

    # Set PS1 from $PreGitPS1 + <git-status> + $PostGitPS1
    __git_ps1 "$PreGitPS1" "$PostGitPS1" " $BOLD(%s$BOLD)$RESET"

    # echo '$PS1='"$PS1" # debug
    # defaut Linux Mint 17.2 user prompt:
    # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[00m\] $(__git_ps1 "(%s)") \$ '
}

# This tells bash to reinterpret PS1 after every command, which we
# need because __git_ps1 will return different text and colors
PROMPT_COMMAND=__set_bash_prompt
