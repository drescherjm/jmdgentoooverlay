#!/bin/sh
cd /sys/devices/system/cpu
echo userspace >cpu0/cpufreq/scaling_governor
echo userspace >cpu1/cpufreq/scaling_governor
while true; do \
       echo 2200000 >cpu0/cpufreq/scaling_setspeed; \
       echo 2200000 >cpu1/cpufreq/scaling_setspeed; \
       sleep 0.3; \
       echo 1000000 >cpu0/cpufreq/scaling_setspeed; \
       echo 1000000 >cpu1/cpufreq/scaling_setspeed; \
       sleep 0.3; \
done

