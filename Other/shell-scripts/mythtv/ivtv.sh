#!/bin/bash
rm /lib/modules/`uname -r`/kernel/drivers/media/video/msp3400.ko
emerge ivtv
