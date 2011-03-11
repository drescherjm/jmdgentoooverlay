#!/bin/bash
mount | grep /tmp/work | awk '{ print $3  }' | xargs -n1 -i umount {}
