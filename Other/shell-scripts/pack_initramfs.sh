#!/bin/sh

echo "Execute this from the root of initramfs tree."

find . | cpio --create --format='newc' | xz --format=lzma --compress --stdout > /tmp/newinitrd.img
