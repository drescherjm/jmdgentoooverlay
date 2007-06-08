# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/nut/nut-2.0.5-r2.ebuild,v 1.5 2007/05/14 19:29:18 jokey Exp $

inherit eutils fixheadtails

MY_P="${P/_/-}"

DESCRIPTION="Network-UPS Tools"
HOMEPAGE="http://www.networkupstools.org/"
# Nut mirrors are presently broken
#SRC_URI="mirror://nut/source/${PV%.*}/${MY_P}.tar.gz"
SRC_URI="http://www.networkupstools.org/source/${PV%.*}/testing/${MY_P}.tar.gz"

S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="cgi snmp usb ssl"

RDEPEND="cgi? ( >=media-libs/gd-2 )
		snmp? ( net-analyzer/net-snmp )
		usb? ( >=dev-libs/libusb-0.1.12 )
		ssl? ( dev-libs/openssl )
		!<sys-fs/udev-104"
DEPEND="$RDEPEND
		>=sys-apps/sed-4
		>=sys-devel/autoconf-2.58"

# public files should be 644 root:root
NUT_PUBLIC_FILES="/etc/nut/{{hosts,upsset,ups,upssched}.conf,upsstats{,-single}.html}"
# private files should be 640 root:nut - readable by nut, writeable by root,
NUT_PRIVATE_FILES="/etc/nut/{upsd.conf,upsd.users,upsmon.conf}"

pkg_setup() {
	enewgroup nut 84
	enewuser nut 84 -1 /var/state/nut nut,uucp
	# As of udev-104, NUT must be in uucp and NOT in tty.
	gpasswd -d nut tty
	gpasswd -a nut uucp
	# in some cases on old systems it wasn't in the nut group either!
	gpasswd -a nut nut
	warningmsg ewarn
}

src_unpack() {
	unpack ${A}

#	EPATCH_OPTS="-p1 -d ${S}" epatch ${FILESDIR}/upsstats-upsset-link-2.0.5.patch
#	EPATCH_OPTS="-p1 -d ${S}" epatch ${FILESDIR}/nut-2.0.5-bcmxcp-3phase.patch

	cd "${S}"

	sed -e "s/install: install-dirs/install: install-dirs install-conf/" \
		-i Makefile.in || die "sed failed"

	ht_fix_file configure.in

	sed -e "s:GD_LIBS.*=.*-L/usr/X11R6/lib \(.*\) -lXpm -lX11:GD_LIBS=\"\1:" \
		-i configure.in || die "sed failed"

	ebegin "Recreating configure"
	WANT_AUTOCONF=2.5 autoconf || die "autoconf failed"
	eend $?
}

src_compile() {
	local myconf

	if [ -n "${NUT_DRIVERS}" ]; then
		myconf="${myconf} --with-drivers=${NUT_DRIVERS// /,}"
	fi

	econf \
		--with-user=nut \
		--with-group=nut \
		--with-drvpath=/lib/nut \
		--sysconfdir=/etc/nut \
		--with-logfacility=LOG_DAEMON \
		--with-statepath=/var/lib/nut \
		$(use_with ssl) \
		$(use_with cgi) \
		$(use_with cgi cgipath /usr/share/nut) \
		${myconf} || die "econf failed"

	emake || die "compile problem"

	if use snmp; then
		emake snmp || die "snmp compile problem"
	fi

	if use usb; then
		emake usb || die "usb compile problem"
	fi

	if use cgi; then
		emake cgi || die "cgi compile problem"
	fi
}

src_install() {
	make DESTDIR="${D}" install install-lib || die "make install failed"

	dodir /sbin
	dosym /lib/nut/upsdrvctl /sbin/upsdrvctl
	# This needs to exist for the scripts
	dosym /lib/nut/upsdrvctl /usr/sbin/upsdrvctl

	if use snmp; then
		make DESTDIR="${D}" install-snmp || die "make install-snmp failed"
	fi

	if use usb; then
		make DESTDIR="${D}" install-usb || die "make install-usb failed"
	fi

	if use cgi; then
		make DESTDIR="${D}" install-cgi || die "make install-cgi failed"
		make DESTDIR="${D}" install-cgi-conf || die "make install-cgi-conf failed"
		einfo "CGI monitoring scripts are installed in /usr/share/nut."
		einfo "copy them to your web server's ScriptPath to activate."
		einfo "If you use lighttpd, see lighttpd_nut.conf in the documentation."
	fi

	# this must be done after all of the install phases
	for i in "${D}"/etc/nut/*.sample ; do
		mv "${i}" "${i/.sample/}"
	done


	dodoc ChangeLog CREDITS INSTALL MAINTAINERS NEWS README UPGRADING \
			docs/{FAQ,*.txt}

	newdoc lib/README README.lib

	dodoc ${FILESDIR}/lighttpd_nut.conf

	docinto cables
	dodoc docs/cables/*


	newinitd "${FILESDIR}/upsd.rc6" upsd
	newinitd "${FILESDIR}/upsdrv.rc6-r1" upsdrv
	newinitd "${FILESDIR}/upsmon.rc6" upsmon

	# This sets up permissions for nut to access a UPS
	insinto /etc/udev/rules.d/
	newins scripts/hotplug-ng/nut-usbups.rules 70-nut-usbups.rules

	keepdir /var/lib/nut

	fperms 0700 /var/lib/nut
	fowners nut:nut /var/lib/nut

	eval fperms 0640 ${NUT_PRIVATE_FILES}
	eval fowners root:nut ${NUT_PRIVATE_FILES}

	eval fperms 0644 ${NUT_PUBLIC_FILES}
	eval fowners root:root ${NUT_PUBLIC_FILES}

	# this is installed for 2.4 and fbsd guys
	if ! has_version sys-fs/udev; then
		insinto /etc/hotplug/usb
		insopts -m 755
		doins scripts/hotplug-ng/nut-usbups.hotplug
	fi
}

pkg_postinst() {
	# this is to ensure that everybody that installed old versions still has
	# correct permissions
	chown nut:nut ${ROOT}/var/lib/nut 2>/dev/null
	chmod 0700 ${ROOT}/var/lib/nut 2>/dev/null

	eval chown root:nut ${ROOT}${NUT_PRIVATE_FILES} 2>/dev/null
	eval chmod 0640 ${ROOT}${NUT_PRIVATE_FILES} 2>/dev/null

	eval chown root:root ${ROOT}${NUT_PUBLIC_FILES} 2>/dev/null
	eval chmod 0644 ${ROOT}${NUT_PUBLIC_FILES} 2>/dev/null

	warningmsg elog
}

warningmsg() {
	msgfunc="$1"
	[ -z "$msgfunc" ] && die "msgfunc not specified in call to warningmsg!"
	${msgfunc} "Please note that NUT now runs under the 'nut' user."
	${msgfunc} "NUT is in the uucp group for access to RS-232 UPS."
	${msgfunc} "However if you use a USB UPS you may need to look at the udev or"
	${msgfunc} "hotplug rules that are installed, and alter them suitably."
}
