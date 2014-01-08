#!/bin/sh
emerge -a1 `eix --only-names -C x11-libs -I qt` `eix --only-names -C dev-qt -I qt`
