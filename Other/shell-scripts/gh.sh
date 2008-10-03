#!/bin/bash 
#
# gh - grep history
#
# A simple script for the forgetful and lazy (I use it all the time).
#
# This script allows you to re-use bash history commands...
# 
# A: ...if you can't remember the whole command or path...
# B: ...if you don't feel like pressing the "up" arrow for 2 minutes...
# C: ...if you are too forgetful or lazy to type "grep <search-string> ~/.bash_history"!
#
# -Mike Putnam   http://www.theputnams.net
#
# Usage: gh <search-string>
#

grep $1 ~/.bash_history

exit 0


