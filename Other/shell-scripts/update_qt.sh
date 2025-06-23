#!/bin/sh
emerge -a1 --autounmask-keep-masks  `eix --only-names -C dev-qt -I qt`
