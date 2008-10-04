#!/sbin/runscript
# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

depend() {
        need net
        use mysql
}

start() {

        ebegin "Starting MythTV Transcoding Daemon"
        start-stop-daemon --start --quiet  \
                --exec /usr/bin/mtd \
                --make-pidfile --pidfile /var/run/mtd.pid \
                --background
        eend $?
}

stop () {
        ebegin "Stopping MythTV Transcoding Daemon"
        start-stop-daemon --stop --quiet --pidfile=/var/run/mtd.pid
        eend $?
}
