#!/bin/bash
#
# ~/.xinitrc
#

# Basic X config
xset s 0 &
xset dpms 0 0 900 &   # 15 minutes
xset r rate 370 20 &
xmodmap ~/.xmodmaprc &

# Apps. Group here so that main execution can proceed while these start up
{
	case "$HOSTNAME" in
		"beacon")
			xset m 1 3
			numlockx on
			#xscreensaver -no-splash
		;;
	esac
	disown
} &> /dev/null &

exec i3 -V -d all > /tmp/i3.log 2>&1
