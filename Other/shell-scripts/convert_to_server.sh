#!/bin/sh
euse -D X gnome kde
for p in /var/db/pkg/gnome-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/kde-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/media-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/x11-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/www-clients/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/games-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/sci-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-office/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-pda/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-emacs/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-mobilephone/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-il8n/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-benchmarks/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-antivirus/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/net-voip/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/net-dialup/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/net-irc/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/lxde-base/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
