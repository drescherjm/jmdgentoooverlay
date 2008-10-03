#! /bin/bash
cat /etc/make.conf | grep '^CFLAGS=' | awk '{ print substr($0,9) }' | awk '{print substr($0,0,length($0) - 1) }'
