#!/bin/bash
mount | grep metro | awk '{ print $3  }' | xargs -n1 -i umount {}
