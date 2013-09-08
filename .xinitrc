#!/bin/bash
#
# ~/.xinitrc
#

# Basic X config
xset s 0 &
xset dpms 0 0 2700 &   # 45 minutes, for TV shows
xset r rate 370 20 &
xmodmap ~/.xmodmaprc &

# Apps. Group here so that main execution can proceed while these start up
{
	clipboard-daemon &
	volwheel &
	case "$HOSTNAME" in
		"beacon")
			xset m 1/1 3 &
			numlockx on &
			#if [ ! -d "/var/run/deluge" ] ; then
				deluged &
				deluge-web &
			#fi
			deluge-gtk &
			xscreensaver -no-splash &
		;;
		"beacon-laptop")
			xset m 3/1 3 &
			wicd-client --tray &
			qbat &
		;;
	esac
	loginmsg --show &
	disown
} &> /dev/null &

#exec openbox-session
#exec i3 --force-xinerama -V -d all | grep -v "_NET_WM_NAME" > /tmp/i3-log 2>&1
exec i3 --force-xinerama -V -d all > /tmp/i3.log 2>&1
