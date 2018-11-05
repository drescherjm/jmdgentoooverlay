#!/bin/sh

lsof -w | grep -e \\.ts -e \\.mpeg -e \\.mpg | awk '{print $NF}' | sort | uniq

