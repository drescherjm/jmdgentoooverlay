#!/bin/bash

echo "WARNINGS:"
grep "TEMPMON" /var/log/messages | grep ": WARNING" | grep -v "temperature" | awk '{ print $7,$8, $9 }' | sort | uniq -c

echo "CRITICAL:"
grep "TEMPMON" /var/log/messages | grep  ": CRITICAL" | grep -v "There are" | awk '{ print $7,$8, $9 }' | sort | uniq -c
