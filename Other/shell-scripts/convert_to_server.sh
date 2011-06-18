#!/bin/sh
for p in /var/db/pkg/gnome-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/kde-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/media-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/x11-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/www-clients/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
