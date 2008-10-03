#! /bin/bash
emerge -C nvidia-glx
opengl-update xorg-x11
rm -rf /usr/lib/opengl/nvidia
emerge nvidia-glx 

