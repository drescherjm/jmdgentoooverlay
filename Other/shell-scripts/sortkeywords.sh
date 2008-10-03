#! /bin/bash

sort /etc/portage/package.keywords | sed 's/[ \t]*$//' | uniq  > /tmp/keywords.sorted
cp /tmp/keywords.sorted /etc/portage/package.keywords

