#! /bin/sh
mythcommflag -f $1 --getskiplist | grep Commercial | sed -e 's/.*: //' -e 's/,/\n/'g
