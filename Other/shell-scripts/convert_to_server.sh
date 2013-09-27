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

# The following are very dangerous 
#equery depends gnome-base/libglade | awk '{ print $1 }' | xargs emerge -C
#equery depends x11-libs/gtk+ | awk '{ print $1 }' | xargs emerge -C

emerge -C net-misc/vinagre  
emerge -C app-arch/file-roller 
emerge -C net-misc/tightvnc 
emerge -C app-editors/qemacs 
emerge -C app-admin/gkrellm  
emerge -C app-editors/emacs 
emerge -C app-editors/xemacs 
emerge -C app-editors/gedit 
emerge -C app-text/evince 
emerge -C app-text/epdfview
emerge -C dev-libs/libunique
emerge -C dev-libs/gdl
emerge -C app-admin/conky
emerge -C app-emulation/virtualbox*
emerge -C app-editors/vim
emerge -C app-editors/gvim
emerge -C mail-client/claws-mail
emerge -C app-editors/bluefish
emerge -C mail-client/thunderbird
emerge -C dev-python/pygtksourceview
emerge -C sys-block/partitionmanager
emerge -C net-libs/libktorrent
emerge -C dev-python/gst-python
emerge -C net-libs/farsight2
emerge -C app-text/texlive-core
emerge -C mail-client/claws-mail
emerge -C sys-block/gparted
emerge -C app-text/libspectre
emerge -C net-libs/xulrunner
emerge -C app-laptop/radeontool
emerge -C net-print/cups-pk-helper
emerge -C dev-python/pycups
emerge -C app-text/podofo
emerge -C net-libs/libmediawiki
emerge -C net-libs/telepathy-farsight
emerge -C sys-apps/groff
emerge -C net-misc/rdesktop
emerge -C sys-fs/mtools
emerge -C dev-python/notify-python

