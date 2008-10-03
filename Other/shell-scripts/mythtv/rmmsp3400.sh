#!/bin/bash

rm /lib/modules/`uname -r`/kernel/drivers/media/video/msp3400.ko
rm /lib/modules/`uname -r`/kernel/drivers/media/video/tuner.ko
rm /lib/modules/`uname -r`/kernel/drivers/media/video/tveeprom.ko
rm /lib/modules/`uname -r`/kernel/drivers/media/video/tda9887.ko

depmod -ae
