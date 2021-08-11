#!/bin/bash
#
# ~/.xinitrc
#

xset dpms 0 0 900 &   # 15 minutes
xset r rate 370 20 &
xset m 1 0 &
xinput --set-prop 8 155 2 0 0 0 2 0 0 0 1
xmodmap ~/.xmodmaprc
xrdb ~/.Xresources
xsetroot -solid "#181b22" &

# Keyring
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

mkdir /tmp/log
exec i3 -V -d all > /tmp/log/i3.log 2>&1

