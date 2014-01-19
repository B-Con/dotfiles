# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# The prompt (PS1) displays a PWD dynamically truncated to the width of the
# console. The prompt is computed in three stages. The first part is the
# username, host, and time info; the second the (truncated) pwd; and the third
# the final design and command prompt.
#     Note that these variables need to be computed real time to get their
# lengths,, so environments variables *don't work* as they get expanded later.
#PS1='[\u@\h \w]\$ '
bash_prompt_cmd() {
	local CY="\[\e[1;36m\]" # Each is 12 chars long
	local BL="\[\e[1;34m\]"
	local WH="\[\e[1;37m\]"
	local BR="\[\e[0;33m\]"
	local RE="\[\e[1;31m\]"
	local PROMPT="${BL}$"
	[ $UID -eq "0" ] && PROMPT="${RE}#"

	# Add the first part of the prompt: username,host, and time
	local PROMPT_PWD=""
	local PS1_T1="$BL.:[ $CY`whoami`@`hostname` $BL| $CY\t $BL|$CY "
	local ps_len=$(( ${#PS1_T1} - 12 * 6 + 6 + 4 )) #Account color, time, var
	local PS1_T2=" $BL]:.\n${PROMPT} \[\e[0m\]"
	local startpos=""

	PROMPT_PWD="${PWD/#$HOME/~}"
	local overflow_prefix="..."
	local pwdlen=${#PROMPT_PWD}
	local maxpwdlen=$(( COLUMNS - ps_len ))
	# Sometimes COLUMNS isn't initialized, if it isn't, fall back to 80.
	[ $maxpwdlen -lt 0 ] && maxpwdlen=$(( 80 - ps_len )) 

	if [ $pwdlen -gt $maxpwdlen ] ; then
		startpos=$(( $pwdlen - maxpwdlen + ${#overflow_prefix} ))
		PROMPT_PWD="${overflow_prefix}${PROMPT_PWD:$startpos:$maxpwdlen}"
	fi	
	export PS1="${PS1_T1}${PROMPT_PWD}${PS1_T2}"
}
PROMPT_COMMAND=bash_prompt_cmd

# History settings
HISTFILESIZE=1000
HISTSIZE=1000
HISTIGNORE="&:[ ]*"
shopt -s histappend
export HISTFILESIZE HISTSIZE HISTIGNORE

# Command aliases
alias arp="arp -n"  # Don't resolve names, can sometimes take forever
alias df="df -BG"
alias diff="colordiff"
alias du-dir="du -ms"  # Megabytes, summarize only the top directory
alias free="free -m"  # Megabytes
alias fuser="fuser -v"
alias g="git"
alias gc="git commit"
alias gl="git log"
alias gpush="git push"
alias gpull="git pull"
alias gs="git status"
alias ls="ls --color=auto"
alias l="ls"
alias ll="ls -lh"
alias la="ls -a"
alias lal="ls -alh"
alias p="pacman"
alias pa="packer --auronly"
alias ping="ping -c 2"  # Ping twice
alias ps-nice="ps -eao nice,pid,cmd"  # Show "niceness" of processes
alias ps-tree="ps -eHo pid,cmd"
alias route="route -n"  # Don't resolve names, can take forever
alias sarpscan="sudo arp-scan --localnet --retry=3 --timeout=300"
alias sp="sudo pacman"
alias spa="sudo packer --auronly"
alias v="vim"
alias vi="vim"
alias xclip="xclip -selection clipboard"

# Tab completion
[ -f /etc/bash_completion ] && . /etc/bash_completion
complete -cf sudo   # Enable completion for sudo

# Misc
#set -o vi
export EDITOR='vim'
export VISUAL='vim'

#[[ -s "/home/b-con/.rvm/scripts/rvm" ]] && source "/home/b-con/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
