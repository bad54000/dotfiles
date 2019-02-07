#!/bin/bash

if [ -n "$1" ]; then
	notify-send "Stan Recherche des trams en cours pour Point Central"
fi

# docker run --rm --name casperjs-daemon -v /home/dany/Dockers/casperjs/tests:/home/casperjs-tests vitr/casperjs casperjs /home/casperjs-tests/mytesting.js

if [ -n "$1" ]; then
	notify-send "Stan update finish !"
fi
