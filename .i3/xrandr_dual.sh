#!/bin/sh

killall polybar
killall polybar
killall polybar
xrandr --output DP-2 --auto --left-of eDP-1
polybar -r main &
polybar -r second &
