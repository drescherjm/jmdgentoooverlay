#! /bin/bash

sh sortworld.sh

emerge $@ `cat /tmp/world.sorted` ; emerge --resume --skipfirst ; emerge --resume --skipfirst ; emerge --resume --skipfirst ; emerge --resume --skipfirst ; emerge --resume --skipfirst
