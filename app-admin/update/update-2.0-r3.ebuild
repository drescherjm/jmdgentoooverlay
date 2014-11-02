# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


DESCRIPTION="Update Script for Gentoo Linux"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

IUSE="daily weekly"

RDEPEND="x11-misc/xdialog
app-portage/eix
app-portage/elogv
app-portage/gentoolkit
app-portage/layman
>=sys-apps/portage-2.2"

src_install() {
        exeinto /usr/bin
        newexe  "${FILESDIR}/update-${PV}" "update"

        insinto /etc/conf.d
        newins "${FILESDIR}/update-conf-${PV}" "update"

        if use daily; then
		dosym /usr/bin/update /etc/cron.daily/update
	elif use weekly; then
		dosym /usr/bin/update /etc/cron.weekly/update
	fi

        ewarn "Please use elogv after each update."
        ewarn "Also remember to run etc-update afterwards!!!"
	ewarn "Configure /etc/conf.d/update before the first run."
	ewarn "Follow it's instructions to set up /etc/make.conf !!!"
}
