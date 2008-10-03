#! /bin/bash
echo "$1 ~x86 ~amd64" >> /etc/portage/package.keywords
echo "$1" >> /etc/portage/package.unmask
