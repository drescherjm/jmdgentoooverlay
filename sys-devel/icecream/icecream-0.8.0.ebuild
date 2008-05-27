# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit autotools eutils flag-o-matic

MY_P="icecc-${PV}"
DESCRIPTION="icecc is a program for distributed compiling of C(++) code across several machines."
HOMEPAGE="http://en.opensuse.org/Icecream"
SRC_URI="ftp://ftp.suse.com/pub/projects/icecream/${MY_P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
DEPEND="virtual/libc"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/0.7.14-dont-create-symlinks.patch
	epatch "${FILESDIR}"/0.7.14-conf.d-verbosity.patch
	epatch "${FILESDIR}"/icecc-make-it-cool.diff

	use amd64 && append-flags -fPIC -DPIC

	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dobin "${FILESDIR}"/icecream-config
	newconfd suse/sysconfig.icecream icecream
	doinitd "${FILESDIR}"/icecream
	diropts -m0755
	keepdir /usr/lib/icecc/bin
	cd "${WORKDIR}"/mans
	doman icecc.1  iceccd.1  icecream.7  scheduler.1
}

pkg_postinst() {
	enewgroup icecream || die "Problem creating icecream group"

	#are we doing bootstrap with has no useradd?
	if [ -x /usr/sbin/useradd ]; then
		enewuser icecream -1 -1 /var/cache/icecream icecream || die "Problem adding icecream user"
	else
		ewarn "You do not have useradd (bootstrap) from shadow so I didn't"
		ewarn "install the icecream user.  Note that attempting to start the daemon"
		ewarn "will fail. Please install shadow and re-emerge icecream."
		ebeep 2
	fi

	if [[ ${ROOT} = "/" ]] ; then
		elog "Scanning for compiler front-ends..."
		/usr/bin/icecream-config --install-links
		/usr/bin/icecream-config --install-links ${CHOST}
	else
		ewarn "Install is incomplete; you must run the following command:"
		ewarn " # icecream-config --install-links ${CHOST}"
		ewarn "after booting or chrooting to ${ROOT} to complete installation."
	fi

	elog
	elog "If you have compiled binutils/gcc/glibc with processor-specific flags"
	elog "(as normal using Gentoo), there is a greater chance that your compiler"
	elog "won't work on other machines. The best would be to build gcc, glibc and"
	elog "binutils without those flags and then copy the needed files into your"
	elog "tarball for distribution to other machines. This tarball can be created"
	elog "by running /usr/bin/icecc --build-native, and used by setting"
	elog "ICECC_VERSION in /etc/conf.d/icecream"
	elog '  ICECC_VERSION=<filename_of_archive_containing_your_environment>'
	elog
	elog "To use icecream with portage add the following line to /etc/make.conf"
	elog '  PREROOTPATH=/usr/lib/icecc/bin'
	elog
	elog "To use icecream with normal make use (e.g. in /etc/profile)"
	elog '  PATH=/usr/lib/icecc/bin:$PATH'
	elog
	elog "N.B. To use icecream with ccache, the ccache PATH should come first:"
	elog '  PATH=/usr/lib/ccache/bin:/usr/lib/icecc/bin:$PATH'
	elog
	elog "Don't forget to open the following ports in your firewall(s):"
	elog " TCP/10245 on the daemon computers (required)"
	elog " TCP/8765 for the the scheduler computer (required)"
	elog " TCP/8766 for the telnet interface to the scheduler (optional)"
	elog " UDP/8765 for broadcast to find the scheduler (optional)"
	elog
	elog "Further usage instructions: http://www.opensuse.org/icecream"
	elog
	elog "The icecream monitor is no longer included in this package."
	elog "See http://bugs.gentoo.org/show_bug.cgi?id=139432 for more info."
}
