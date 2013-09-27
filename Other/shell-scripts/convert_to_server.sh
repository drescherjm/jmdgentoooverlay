#!/bin/sh
euse -D X gnome kde
for p in /var/db/pkg/gnome-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/kde-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/media-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/x11-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/www-client*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
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
for p in /var/db/pkg/xfce-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-xemacs/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/net-im/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/rox-*/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/net-zope/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/net-wireless/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/net-p2p/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-accessibility/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
for p in /var/db/pkg/app-cdr/*; do echo $p|sed -e 's#.*/#=#' ; done | xargs emerge -C
emerge -C net-misc/vinagre app-arch/file-roller net-misc/tightvnc app-editors/qemacs app-admin/gkrellm  app-editors/emacs app-editors/xemacs app-editors/gedit app-text/evince 
