# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/bacula/bacula-2.2.7.ebuild,v 1.2 2008/01/01 09:41:28 mabi Exp $

#
# TODO:
# - install stuff from examples/:
#	- examples/nagios/ + add nagios USE flag etc.
#	  (see also example/reports/check_bacula_pools.sh which is newer
#	  than examples/nagios/check_bacula_pools.sh)
#   - examples/autochangers/
#   - examples/devices/
#   - examples/python/
#   - examples/reports/baculareport.pl
# - correctly filter unneeded /usr/libexec/bacula/ stuff depending
#   on selected USE flags, e.g. bacula-clientonly
# - install bacula-web and/or bweb from bacula-gui package
#

inherit eutils

IUSE="bacula-clientonly bacula-console bacula-nodir bacula-nosd bacula-split-init doc gnome ipv6 logrotate logwatch mysql postgres python qt4 readline sqlite sqlite3 ssl static tcpd wxwindows X"
KEYWORDS="~amd64 ~hppa ~ppc ~sparc ~x86"

DESCRIPTION="Featureful client/server network backup suite"
HOMEPAGE="http://www.bacula.org/"

DOC_VER="${PV}"
SRC_URI="mirror://sourceforge/bacula/${P}.tar.gz
		doc? ( mirror://sourceforge/bacula/${PN}-docs-${DOC_VER}.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"

DEPEND="
	>=sys-libs/zlib-1.1.4
	dev-libs/gmp
	!bacula-clientonly? (
		postgres? ( >=dev-db/postgresql-7.4.0 )
		mysql? ( virtual/mysql )
		sqlite? ( =dev-db/sqlite-2* )
		sqlite3? ( >=dev-db/sqlite-3.0.0 )
		virtual/mta
	)
	bacula-console? (
		wxwindows? ( =x11-libs/wxGTK-2.6* )
		qt4? (
			=x11-libs/qt-4*
			>=x11-libs/qwt-5
		)
		gnome? (
			>=gnome-base/libgnome-2
			x11-libs/gksu
		)
	)
	ssl? ( dev-libs/openssl )
	logrotate? ( app-admin/logrotate )
	logwatch? ( sys-apps/logwatch )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	readline? ( >=sys-libs/readline-4.1 )
	doc? (
		virtual/ghostscript
		dev-tex/latex2html
	)"
RDEPEND="${DEPEND}
	!bacula-clientonly? (
		sys-block/mtx
		app-arch/mt-st
	)"

pkg_setup() {
	local dbnum
	declare -i dbnum=0
	if ! useq bacula-clientonly; then
		if useq mysql; then
			export mydbtype='mysql'
			let dbnum++
		fi
		if useq postgres; then
			export mydbtype='postgresql'
			let dbnum++
		fi
		if useq sqlite; then
			export mydbtype='sqlite'
			let dbnum++
		fi
		if useq sqlite3; then
			export mydbtype='sqlite3'
			let dbnum++
		fi
		if [[ "${dbnum}" -lt 1 ]]; then
			eerror
			eerror "To use ${P} it is required to set a database in the USE flags."
			eerror "Supported databases are mysql, postgresql, sqlite, sqlite3"
			eerror
			die "No database type selected."
		elif [[ "${dbnum}" -gt 1 ]]; then
			eerror
			eerror "You have set ${P} to use multiple database types."
			eerror "I don't know which to set as the default!"
			eerror "You can use /etc/portage/package.use to set per-package USE flags"
			eerror "Set it so only one database type, mysql, postgres, sqlite, sqlite3"
			eerror
			die "Multiple database types selected."
		fi
	fi

	# create the daemon group and user
	if [ -z "$(egetent group bacula)" ]; then
		enewgroup bacula
		einfo
		einfo "The group 'bacula' has been created. Any users you add to this"
		einfo "group have access to files created by the daemons."
		einfo
	fi
	if ! useq bacula-clientonly; then
		if [ -z "$(egetent passwd bacula)" ]; then
			enewuser bacula -1 -1 /var/lib/bacula bacula,disk,tape,cdrom,cdrw
			einfo
			einfo "The user 'bacula' has been created.  Please see the bacula manual"
			einfo "for information about running bacula as a non-root user."
			einfo
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# adjusts default configuration files for several binaries
	# to /etc/bacula/<config> instead of ./<config>
	pushd src && epatch "${FILESDIR}/${PV}/${PN}"-default-configs.patch && popd

	# replaces (deprecated) gnomesu with gksu in the gnome menu files
	useq bacula-console && useq gnome && epatch "${FILESDIR}/${PV}/${PN}"-gnomesu2gksu.diff
}

src_compile() {
	local myconf=''

	if useq bacula-clientonly; then
		myconf="${myconf} \
			$(use_enable bacula-clientonly client-only) \
			$(use_enable static static-fd)"
	else
		myconf="${myconf} \
			--with-${mydbtype} \
			$(use_enable static static-tools) \
			$(use_enable static static-fd) \
			$(use_enable !bacula-nodir build-dird) \
			$(use_enable !bacula-nosd build-stored)"
		if ! useq bacula-nodir; then
			myconf="${myconf} $(use_enable static static-dir)"
		fi
		if ! useq bacula-nosd; then
			myconf="${myconf} $(use_enable static static-sd)"
		fi

	fi

	if useq bacula-console; then
		if useq qt4 && has_version '<x11-libs/qwt-5'; then
			eerror "x11-libs/qwt found in a version < 5, thus the"
			eerror "compilation of 'bat' would fail (see"
			eerror "http://bugs.gentoo.org/188477#c11 for details)."
			eerror "please either unmerge <x11-libs/qwt-5 or disable"
			eerror "the qt4 USE flag to disable building 'bat'."
			die "incompatible slotted qwt version found"
		fi
		myconf="${myconf} \
			$(use_with X x) \
			$(use_enable gnome) \
			$(use_enable gnome tray-monitor) \
			$(use_enable wxwindows bwx-console) \
			$(use_enable qt4 bat) \
			$(use_enable static static-cons)"
	fi

	myconf="${myconf} \
		$(use_with python) \
		$(use_enable readline) \
		$(use_with readline readline /usr) \
		$(use_with ssl openssl) \
		$(use_enable ipv6) \
		$(use_with tcpd tcp-wrappers)"

	./configure \
		--prefix=/usr \
		--mandir=/usr/share/man \
		--with-pid-dir=/var/run \
		--sysconfdir=/etc/bacula \
		--infodir=/usr/share/info \
		--with-subsys-dir=/var/lock/subsys \
		--with-working-dir=/var/lib/bacula \
		--with-scriptdir=/usr/libexec/bacula \
		--with-dir-user=bacula \
		--with-dir-group=bacula \
		--with-sd-user=root \
		--with-sd-group=bacula \
		--with-fd-user=root \
		--with-fd-group=bacula \
		--enable-smartalloc \
		--host=${CHOST} \
		${myconf} \
		|| die "configure failed"

	emake || die "emake failed"

	# build docs from bacula-docs tarball
	if useq doc; then
		pushd "${WORKDIR}/${PN}-docs-${DOC_VER}"

		./configure \
			--with-bacula="${S}" \
			|| die "configure for bacula-docs failed"

		# the main Makefile tries to build stuff in
		# ./developer/ and ./bacula-web/, which is
		# unfortunately broken in 2.0.3, so we only
		# build stuff in ./manual/, which works.
		pushd manual
		emake -j1 || die "emake for bacula-docs failed"
		popd

		popd
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# install bat when enabled (for some reason ./configure doesn't pick this up)
	if useq bacula-console && useq qt4; then
		dosbin "${S}"/src/qt-console/bat
	fi

	# remove some scripts we don't need at all
	rm -f "${D}"/usr/libexec/bacula/{bacula,bacula-ctl-dir,bacula-ctl-fd,bacula-ctl-sd,startmysql,stopmysql}

	# rename statically linked apps
	if useq static; then
		pushd "${D}"/usr/sbin
		mv static-bacula-fd bacula-fd
		mv static-bconsole bconsole
		if ! useq bacula-clientonly; then
			mv static-bacula-dir bacula-dir
			mv static-bacula-sd bacula-sd
		fi
		if useq bacula-console && useq gnome; then
			mv static-gnome-console gnome-console
		fi
		if useq bacula-console && useq qt4; then
			mv static-bat bat
		fi
		popd
	fi

	# gnome-console menu entries using gksu
	if useq bacula-console && useq gnome; then
		emake DESTDIR="${D}" install-menu-xsu \
			|| die "Failed to install gnome menu files"
	fi

	# extra files which 'make install' doesn't cover
	if ! useq bacula-clientonly; then
	    # the database update scripts
		diropts -m0750
		insinto /usr/libexec/bacula/updatedb
		insopts -m0754
		doins "${S}"/updatedb/*
		fperms 0640 /usr/libexec/bacula/updatedb/README

		# the logrotate configuration
		if useq logrotate; then
			diropts -m0755
			insinto /etc/logrotate.d
			insopts -m0644
			newins "${S}"/scripts/logrotate bacula
		fi

		# the logwatch scripts
		if useq logwatch; then
			diropts -m0750
			dodir /etc/log.d/scripts/services
			dodir /etc/log.d/conf/logfiles
			dodir /etc/log.d/conf/services
			cd "${S}"/scripts/logwatch
			emake DESTDIR="${D}" install || die "Failed to install logwatch scripts"
			cd "${S}"
		fi
	fi

	# documentation
	for d in "${S}"/{ChangeLog,LICENSE,README,ReleaseNotes,SUPPORT,kernstodo,projects}; do
		dodoc "${d}"
	done
	# TODO FIXME: developers and bacula-web documentation is broken with 2.0.3 :-(
	if useq doc; then
#!		dodoc "${WORKDIR}/${PN}-docs-${DOC_VER}"/developers/developers.pdf
		dodoc "${WORKDIR}/${PN}-docs-${DOC_VER}"/manual/bacula.pdf
		diropts -m0755
#!		dodir /usr/share/doc/"${PF}"/developers
		dodir /usr/share/doc/"${PF}"/manual
		insopts -m0644
#!		insinto /usr/share/doc/"${PF}"/developers
#!		doins "${WORKDIR}/${PN}-docs-${DOC_VER}"/developers/developers/*
		insinto /usr/share/doc/"${PF}"/manual
		doins "${WORKDIR}/${PN}-docs-${DOC_VER}"/manual/bacula/*
	fi

	# setup init scripts
	myservices="fd"
	if ! useq bacula-clientonly; then
		if ! useq bacula-nodir; then
			myservices="${myservices} dir"
		fi
		if ! useq bacula-nosd; then
			myservices="${myservices} sd"
		fi
	fi
	if useq bacula-split-init; then
		myscripts=""
		for service in ${myservices}; do
			myscripts="${myscripts} bacula-${service}"
		done
	else
		myscripts="bacula-all"
	fi
	for script in ${myscripts}; do
		# copy over init script and config to a temporary location
		# so we can modify them as needed
		cp "${FILESDIR}/${PV}/${script}"-conf "${T}/${script}".conf
		cp "${FILESDIR}/${PV}/${script}"-init "${T}/${script}".init
		# set database dependancy for the all-in-one and director init scripts
		case "${mydbtype}" in
			sqlite*)
				# sqlite + sqlite3 databases don't have daemons
				sed -i -e "s:%database%::" "${T}/${script}".init
				;;
			*)
				# all other databases have daemons
				sed -i -e "s:%database%:${mydbtype}:" "${T}/${script}".init
				;;
		esac
		# set services for the all-in-one init script
		sed -i -e "s:%services%:${myservices}:" "${T}/${script}".conf
		# install init script and config
		newinitd "${T}/${script}".init "${script}"
		newconfd "${T}/${script}".conf "${script}"
	done

	# make sure the working directory exists
	diropts -m0750
	keepdir /var/lib/bacula

	# make sure bacula group can execute bacula libexec scripts
	fowners root:bacula /usr/libexec/bacula/*
}

pkg_postinst() {
	if useq bacula-clientonly; then
		fowners root:bacula /var/lib/bacula
	else
		fowners bacula:bacula /var/lib/bacula
	fi

	if ! useq bacula-clientonly && ! useq bacula-nodir; then
		einfo
		einfo "If this is a new install, you must create the ${mydbtype} databases with:"
		einfo "  /usr/libexec/bacula/create_${mydbtype}_database"
		einfo "  /usr/libexec/bacula/make_${mydbtype}_tables"
		einfo "  /usr/libexec/bacula/grant_${mydbtype}_privileges"
		einfo
		einfo "If you're upgrading from a major release, you must upgrade your bacula catalog database."
		einfo "Please read the manual chapter for how to upgrade your database."
		einfo "You can find database upgrade scripts in /usr/libexec/bacula/updatedb."
		einfo
	fi
}
