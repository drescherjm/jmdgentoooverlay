#!/bin/bash

echo "WARNINGS:"
grep "logger: WARNING" /var/log/messages | grep -v "The temperature" | awk '{ print $7,$8, $9 }' | sort | uniq -c

echo "CRITICAL:"
grep "logger: CRITICAL" /var/log/messages | grep -v "There are" | awk '{ print $7,$8, $9 }' | sort | uniq -c
