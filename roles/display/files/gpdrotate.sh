#!/bin/sh

sleep 5

DISPLAY=:${1}
XAUTHORITY=$(ps aux |grep -e Xorg | head -n1 | awk '{ split($0, a, "-auth "); split(a[2], b, " "); print b[1] }')
export DISPLAY XAUTHORITY

xrandr --output DSI1 --rotate right