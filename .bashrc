# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# The prompt (PS1) displays a PWD dynamically truncated to the width of the
# console. The prompt is computed in three stages. The first part is the
# username, host, and time info; the second the (truncated) pwd; and the third
# the final design and command prompt.
#     Note that these variables need to be computed real time to get their
# lengths,, so environments variables *don't work* as they get expanded later.
bash_prompt_cmd_basic() {
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

	PROMPT_PWD="${PWD/#$HOME/\~}"
	local overflow_prefix="…"   # Unicode 0x2026
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

bash_prompt_cmd_full() {
	# Prompt colors
	local B="\[\e[1m\]"          # bold
	local RESET="\[\e[0m\]"
	local BG=""
	#local BG="\[\e[48;5;253m\]"   # background color
	local CS="\[\e[38;5;47m\]"   # seperator
	local CU="\[\e[38;5;45m\]"   # username
	local CH="\[\e[38;5;172m\]"   # host
	local CT="\[\e[38;5;45m\]"   # time
	local CD="\[\e[38;5;45m\]"   # working directory
	local CP="\[\e[38;5;47m\]$"  # prompt
	[ $UID -eq "0" ] && CP="\[\e[38;5;160m\]#" # root prompt
	local CI=$RESET              # input
	
	# Add the first part of the prompt: username,host, and time
	local PS1_L1_1="$B$BG$CS.:[ $CU$CACHE_WHOAMI$CS@$CH$CACHE_HOSTNAME$CS | $CT\t$CS | $CD"
	local PS1_L1_2="$CS ]:.$RESET"
	local PS1_L2="\n${CP} ${CI}"
	
	# Calculate the actual length of the line so far, minus the extra formatting.
	# Just count the control codes in the PS1_L2_* vars above.
	# The difference between the time and the string is 6.
	local ps_len=$(( ${#PS1_L1_1} + ${#PS1_L1_2} + 6 - 15 * 9 ))

	[[ ! $COLUMNS ]] && COLUMNS=80
	local maxpwdlen=$(( COLUMNS - ps_len ))
	
	local PROMPT_PWD="${PWD/#$HOME/\~}"
	local pwdlen=${#PROMPT_PWD}
	
	# Truncate the PWD to fit.
	if [ $pwdlen -gt $maxpwdlen ] ; then
		local overflow_prefix="…"   # U+2026
		local startpos=$(( $pwdlen - maxpwdlen + ${#overflow_prefix} ))
		PROMPT_PWD="${overflow_prefix}${PROMPT_PWD:$startpos:$maxpwdlen}"
	fi	
	export PS1="${PS1_L1_1}${PROMPT_PWD}${PS1_L1_2}${PS1_L2}"
}
PS1='.:[\u@\h | \t | \w]:.\n$ '
if [[ "$TERM" =~ 256color ]]; then
	PROMPT_COMMAND=bash_prompt_cmd_full
	# Cache the username and hostname strings for the prompt.
	export CACHE_WHOAMI=`whoami`
	export CACHE_HOSTNAME=`hostname`
fi

# History settings
HISTFILESIZE=100000
HISTSIZE=100000
HISTIGNORE="history:histsync:exit:clear"
HISTCONTROL="ignorespace:ignoredups"
shopt -s histappend
shopt -s checkwinsize
export HISTFILESIZE HISTSIZE HISTIGNORE

# Tab completion
[ -f /etc/bash_completion ] && source /etc/bash_completion
complete -cf sudo   # Enable completion for sudo

# Command aliases
alias arp="arp -n"  # Don't resolve names, can sometimes take forever
alias df="df -h"
alias diff="colordiff"
alias du-dir="du -msh"  # Megabytes, summarize only the top directory
alias free="free -h"
alias fuser="fuser -v"
alias g="git"
alias gc="git commit"
alias gl="git log"
alias gpush="git push"
alias gpull="git pull"
alias grep="grep --color=auto"
alias gs="git status"
alias histsync="history -n; history -w; history -c; history -r"   # Sync history and reload it (respecting dups settings).
alias ls="ls --color=auto"
alias l="ls"
alias ll="ls -lh"
alias la="ls -a"
alias lal="ls -alh"
alias p="pacman"
alias pa="pacaur"
alias ping="ping -c 2"  # Ping twice
alias ps-nice="ps -eao nice,pid,cmd"  # Show "niceness" of processes
alias ps-tree="ps -eHo pid,cmd"
alias route="route -n"  # Don't resolve names, can take forever
alias sarpscan="sudo arp-scan --localnet --retry=3 --timeout=300"
alias sp="sudo pacman"
alias spa="sudo pacaur"
alias v="vim"
alias vi="vim"
alias xclip="xclip -selection clipboard"

# Misc
export EDITOR='vim'
export VISUAL='vim'

