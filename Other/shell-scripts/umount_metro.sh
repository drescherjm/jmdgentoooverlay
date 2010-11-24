#!/bin/bash
mount | grep /var/tmp/metro | awk '{ print $3  }' | xargs -n1 -i umount {}
