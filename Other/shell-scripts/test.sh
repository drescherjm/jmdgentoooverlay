#! /bin/bash

sh sortworld.sh

emerge -u$1 $2 `cat /tmp/world.sorted` 
