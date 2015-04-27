#!/bin/sh

umask 0022

. $HOME/.bashrc

# Include custom bin paths
[ -d ~/bin ] && export PATH="${PATH}:~/bin"
[ -d /opt/android/platform-tools ] && export PATH="${PATH}:/opt/android/platform-tools"
[ -d /usr/lib/jvm/java-7-openjdk/bin ] && export PATH="${PATH}:/usr/lib/jvm/java-7-openjdk/bin"

# Start X if logging on locally
if [[ -z "$DISPLAY" ]] && [[ $(tty) = "/dev/tty1" ]]; then
	startx
	# Do not logout, exiting X may not imply desire to logout
fi

# Always keep a screen session
#screen -d -m -S misc

