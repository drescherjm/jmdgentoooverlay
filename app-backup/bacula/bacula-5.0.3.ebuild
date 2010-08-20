# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/bacula/bacula-5.0.3.ebuild,v 1.7 2010/07/17 09:34:59 ssuominen Exp $

EAPI="2"
inherit eutils multilib

IUSE="bacula-clientonly bacula-nodir bacula-nosd ipv6 logwatch mysql postgres python qt4 readline +sqlite3 ssl static tcpd X"
# bacula-web bimagemgr brestore bweb
KEYWORDS="amd64 hppa ~ppc sparc x86"

DESCRIPTION="Featureful client/server network backup suite"
HOMEPAGE="http://www.bacula.org/"

MY_PV=${PV/_beta/-b}
MY_P=${PN}-${MY_PV}
S=${WORKDIR}/${MY_P}
#DOC_VER="${MY_PV}"
#DOC_SRC_URI="mirror://sourceforge/bacula/${PN}-docs-${DOC_VER}.tar.bz2"
#GUI_VER="${PV}"
#GUI_SRC_URI="mirror://sourceforge/bacula/${PN}-gui-${GUI_VER}.tar.gz"
SRC_URI="mirror://sourceforge/bacula/${MY_P}.tar.gz"
#		doc? ( ${DOC_SRC_URI} )
#		bacula-web? ( ${GUI_SRC_URI} )
#		bimagemgr? ( ${GUI_SRC_URI} )
#		brestore? ( ${GUI_SRC_URI} )
#		bweb? ( ${GUI_SRC_URI} )

LICENSE="GPL-2"
SLOT="0"

DEPEND="
	>=sys-libs/zlib-1.1.4
	dev-libs/gmp
	!bacula-clientonly? (
		postgres? ( dev-db/postgresql-server )
		mysql? ( virtual/mysql )
		sqlite3? ( dev-db/sqlite:3 )
		!bacula-nodir? ( virtual/mta )
	)
	qt4? (
		x11-libs/qt-svg:4
		>=x11-libs/qwt-5
	)
	ssl? ( dev-libs/openssl )
	logwatch? ( sys-apps/logwatch )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	readline? ( >=sys-libs/readline-4.1 )
	sys-libs/ncurses
	python? ( dev-lang/python[threads] )"
#	doc? (
#		app-text/ghostscript-gpl
#		dev-tex/latex2html[png]
#		app-text/dvipdfm
#	)
RDEPEND="${DEPEND}
	!bacula-clientonly? (
		!bacula-nosd? (
			sys-block/mtx
			app-arch/mt-st
		)
	)"

pkg_setup() {
	local -i dbnum=0
	if ! use bacula-clientonly; then
		if use mysql; then
			export mydbtype=mysql
			let dbnum++
		fi
		if use postgres; then
			export mydbtype=postgresql
			let dbnum++
		fi
		if use sqlite3; then
			export mydbtype=sqlite3
			let dbnum++
		fi
		if [[ "${dbnum}" -lt 1 ]]; then
			eerror
			eerror "To use ${P} it is required to set a database in the USE flags."
			eerror "Supported databases are mysql, postgresql, sqlite3"
			eerror
			die "No database type selected."
		elif [[ "${dbnum}" -gt 1 ]]; then
			eerror
			eerror "You have set ${P} to use multiple database types."
			eerror "I don't know which to set as the default!"
			eerror "You can use /etc/portage/package.use to set per-package USE flags"
			eerror "Set it so only one database type, mysql, postgres, sqlite3"
			eerror
			die "Multiple database types selected."
		fi
	fi

	# create the daemon group and user
	if [ -z "$(egetent group bacula 2>/dev/null)" ]; then
		enewgroup bacula || die
		einfo
		einfo "The group 'bacula' has been created. Any users you add to this"
		einfo "group have access to files created by the daemons."
		einfo
	fi
	if ! use bacula-clientonly; then
		if [ -z "$(egetent passwd bacula 2>/dev/null)" ]; then
			enewuser bacula -1 -1 /var/lib/bacula bacula,disk,tape,cdrom,cdrw || die
			einfo
			einfo "The user 'bacula' has been created.  Please see the bacula manual"
			einfo "for information about running bacula as a non-root user."
			einfo
		fi
	fi
}

src_prepare() {
	# adjusts default configuration files for several binaries
	# to /etc/bacula/<config> instead of ./<config>
	pushd src >&/dev/null || die
	for f in console/console.c dird/dird.c filed/filed.c \
		stored/bcopy.c stored/bextract.c stored/bls.c \
		stored/bscan.c stored/btape.c stored/stored.c \
		qt-console/main.cpp; do
		sed -i -e 's|^\(#define CONFIG_FILE "\)|\1/etc/bacula/|g' "${f}" \
			|| die "sed on ${f} failed"
	done
	popd >&/dev/null || die

	# bug #310087
	epatch "${FILESDIR}"/${PV}/${P}-as-needed.patch

	# bug #311161
	epatch "${FILESDIR}"/${PV}/${P}-lib-search-path.patch

	epatch "${FILESDIR}"/${PV}/${P}-openssl-1.patch
}

src_configure() {
	local myconf=''

	if use bacula-clientonly; then
		myconf="${myconf} \
			$(use_enable bacula-clientonly client-only) \
			$(use_enable static static-fd)"
	else
		myconf="${myconf} \
			$(use_enable qt4 bat) \
			$(use_enable static static-tools) \
			$(use_enable static static-fd) \
			$(use_enable !bacula-nodir build-dird) \
			$(use_enable !bacula-nosd build-stored)"
		# bug #311099
		# database support needed by dir-only *and* sd-only
		# build as well (for building bscan, btape, etc.)
		myconf="${myconf} \
			--with-${mydbtype} \
			--enable-batch-insert"
		if ! use bacula-nodir; then
			myconf="${myconf} $(use_enable static static-dir)"
		fi
		if ! use bacula-nosd; then
			myconf="${myconf} $(use_enable static static-sd)"
		fi
	fi

	myconf="${myconf} \
		--disable-tray-monitor \
		$(use_with X x) \
		$(use_enable static static-cons)
		$(use_with python) \
		$(use_enable !readline conio) \
		$(use_enable readline) \
		$(use_with readline readline /usr) \
		$(use_with ssl openssl) \
		$(use_enable ipv6) \
		$(use_with tcpd tcp-wrappers)"

	econf \
		--libdir=/usr/$(get_libdir) \
		--docdir=/usr/share/doc/${PF} \
		--htmldir=/usr/share/doc/${PF}/html \
		--with-pid-dir=/var/run \
		--sysconfdir=/etc/bacula \
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
		|| die "econf failed"
}

src_compile() {
	emake || die "emake failed"

	# build various GUIs from bacula-gui tarball
#	if use bacula-web || use bimagemgr || use brestore || use bweb; then
#		pushd "${WORKDIR}/${PN}-gui-${GUI_VER}"
#		local myconf_gui=''
#		if use bimagemgr; then
#			## TODO FIXME: webapp-config? !apache?
#			myconf_gui="${myconf_gui} \
#				--with-bimagemgr-cgidir=/var/www/localhost/cgi-bin \
#				--with-bimagemgr-docdir=/var/www/localhost/htdocs \
#				--with-bimagemgr-binowner=root \
#				--with-bimagemgr-bingroup=root \
#				--with-bimagemgr-dataowner=apache \
#				--with-bimagemgr-datagroup=apache \
#				"
#		fi
#		./configure \
#			--with-bacula="${S}" \
#			${myconf} \
#			|| die "configure for bacula-gui failed"
#		## TODO FIXME: install files (see bacula-gui.spec)
#		if use bacula-web; then
#			: install
#		fi
#		if use bimagemgr; then
#			: install
#		fi
#		if use brestore; then
#			: install
#		fi
#		if use bweb; then
#			: install
#		fi
#		popd
#	fi

	# build docs from bacula-docs tarball
#	if use doc; then
#		pushd "${WORKDIR}/${PN}-docs-${DOC_VER}"
#		./configure \
#			--with-bacula="${S}" \
#			|| die "configure for bacula-docs failed"
#		emake -j1 || die "emake for bacula-docs failed"
#		popd
#	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# remove some scripts we don't need at all
	rm -f "${D}"/usr/libexec/bacula/{bacula,bacula-ctl-dir,bacula-ctl-fd,bacula-ctl-sd,startmysql,stopmysql}

	# rename statically linked apps
	if use static; then
		pushd "${D}"/usr/sbin || die
		mv static-bacula-fd bacula-fd || die
		mv static-bconsole bconsole || die
		if ! use bacula-clientonly; then
			mv static-bacula-dir bacula-dir || die
			mv static-bacula-sd bacula-sd || die
		fi
		if use qt4; then
			mv static-bat bat || die
		fi
		popd || die
	fi

	# extra files which 'make install' doesn't cover
	if ! use bacula-clientonly; then
		# install bat when enabled (for some reason ./configure doesn't pick this up)
		if use qt4; then
			dosbin "${S}"/src/qt-console/.libs/bat || die
		fi
	    # the database update scripts
		diropts -m0750
		insinto /usr/libexec/bacula/updatedb
		insopts -m0754
		doins "${S}"/updatedb/* || die
		fperms 0640 /usr/libexec/bacula/updatedb/README || die

		# the logrotate configuration
		# (now unconditional wrt bug #258187)
		diropts -m0755
		insinto /etc/logrotate.d
		insopts -m0644
		newins "${S}"/scripts/logrotate bacula || die

		# the logwatch scripts
		if use logwatch; then
			diropts -m0750
			dodir /etc/log.d/scripts/services
			dodir /etc/log.d/scripts/shared
			dodir /etc/log.d/conf/logfiles
			dodir /etc/log.d/conf/services
			pushd "${S}"/scripts/logwatch >&/dev/null || die
			emake DESTDIR="${D}" install || die "Failed to install logwatch scripts"
			popd >&/dev/null || die
		fi
	fi

	# remove unwanted files
	if use bacula-clientonly; then
		rm -vf "${D}"/etc/bacula/bconsole.conf
		rm -vf "${D}"/usr/sbin/bconsole
		rm -vf "${D}"/usr/libexec/bacula/bconsole
	fi
	rm -vf "${D}"/usr/share/man/man1/bacula-bwxconsole.1*
	if use bacula-clientonly || ! use qt4; then
		rm -vf "${D}"/usr/share/man/man1/bat.1*
	fi
	rm -vf "${D}"/usr/share/man/man1/bacula-tray-monitor.1*
	if use bacula-clientonly || use bacula-nodir; then
		rm -vf "${D}"/usr/share/man/man8/bacula-dir.8*
		rm -vf "${D}"/usr/share/man/man8/dbcheck.8*
		rm -vf "${D}"/usr/share/man/man1/bsmtp.1*
		rm -vf "${D}"/usr/libexec/bacula/create_*_database
		rm -vf "${D}"/usr/libexec/bacula/drop_*_database
		rm -vf "${D}"/usr/libexec/bacula/make_*_tables
		rm -vf "${D}"/usr/libexec/bacula/update_*_tables
		rm -vf "${D}"/usr/libexec/bacula/drop_*_tables
		rm -vf "${D}"/usr/libexec/bacula/grant_*_privileges
		rm -vf "${D}"/usr/libexec/bacula/*_catalog_backup
	fi
	if use bacula-clientonly || use bacula-nosd; then
		rm -vf "${D}"/usr/share/man/man8/bacula-sd.8*
		rm -vf "${D}"/usr/share/man/man8/bcopy.8*
		rm -vf "${D}"/usr/share/man/man8/bextract.8*
		rm -vf "${D}"/usr/share/man/man8/bls.8*
		rm -vf "${D}"/usr/share/man/man8/bscan.8*
		rm -vf "${D}"/usr/share/man/man8/btape.8*
		rm -vf "${D}"/usr/libexec/bacula/disk-changer
		rm -vf "${D}"/usr/libexec/bacula/mtx-changer
		rm -vf "${D}"/usr/libexec/bacula/dvd-handler
	fi

	# documentation
	ecompress "${D}"/usr/share/doc/${PF}/*
#	if use doc; then
#		for i in catalog concepts console developers install problems utility; do
#			dodoc "${WORKDIR}/${PN}-docs-${DOC_VER}"/manuals/en/${i}/${i}.pdf || die
#		done
#	fi

	# setup init scripts
	myscripts="bacula-fd"
	if ! use bacula-clientonly; then
		if ! use bacula-nodir; then
			myscripts="${myscripts} bacula-dir"
		fi
		if ! use bacula-nosd; then
			myscripts="${myscripts} bacula-sd"
		fi
	fi
	for script in ${myscripts}; do
		# copy over init script and config to a temporary location
		# so we can modify them as needed
		cp "${FILESDIR}/${PV}/${script}".confd "${T}/${script}".confd || die "failed to copy ${script}.confd"
		cp "${FILESDIR}/${PV}/${script}".initd "${T}/${script}".initd || die "failed to copy ${script}.initd"
		# set database dependancy for the director init script
		case "${script}" in
			bacula-dir)
				case "${mydbtype}" in
					sqlite3)
						# sqlite3 databases don't have a daemon
						sed -i -e 's/need "%database%"/:/g' "${T}/${script}".initd || die
						;;
					*)
						# all other databases have daemons
						sed -i -e "s:%database%:${mydbtype}:" "${T}/${script}".initd || die
						;;
				esac
				;;
			*)
				;;
		esac
		# install init script and config
		newinitd "${T}/${script}".initd "${script}" || die
		newconfd "${T}/${script}".confd "${script}" || die
	done

	# make sure the working directory exists
	diropts -m0750
	keepdir /var/lib/bacula

	# make sure bacula group can execute bacula libexec scripts
	fowners -R root:bacula /usr/libexec/bacula
}

pkg_postinst() {
	if use bacula-clientonly; then
		fowners root:bacula /var/lib/bacula
	else
		fowners bacula:bacula /var/lib/bacula
	fi

	if ! use bacula-clientonly && ! use bacula-nodir; then
		einfo
		einfo "If this is a new install, you must create the ${mydbtype} databases with:"
		einfo "  /usr/libexec/bacula/create_${mydbtype}_database"
		einfo "  /usr/libexec/bacula/make_${mydbtype}_tables"
		einfo "  /usr/libexec/bacula/grant_${mydbtype}_privileges"
		einfo
		echo

		ewarn
		ewarn "*** ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ***"
		ewarn
		ewarn "If you're upgrading from a major release, you must upgrade your bacula catalog database."
		ewarn "Please read the manual chapter for how to upgrade your database."
		ewarn "You can find database upgrade scripts in /usr/libexec/bacula/updatedb/."
		ewarn
		ewarn "*** ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ***"
		ewarn
		ebeep 5
		epause 10
		echo

		ewarn
		ewarn "*** ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ***"
		ewarn
		ewarn "The bundled catalog backup script (/usr/libexec/bacula/make_catalog_backup)"
		ewarn "is INSECURE. The script needs to be called with the database access password"
		ewarn "as a command line parameter, thus, the password can be seen from any other"
		ewarn "user on the system (if not using some non-default hardened/patched kernel"
		ewarn "with /proc restrictions)!"
		ewarn
		ewarn "Our advice is to NOT USE the bundled script at all, but instead use something"
		ewarn "like this in your catalog backup job definition (example using MySQL as the"
		ewarn "catalog database):"
		ewarn
		ewarn "RunBeforeJob = \"mysqldump --defaults-file=/etc/bacula/my.cnf --opt -f -r /var/lib/bacula/bacula.sql bacula\""
		ewarn "RunAfterJob  = \"rm -f /var/lib/bacula/bacula.sql\""
		ewarn
		ewarn "This requires you to put all database access parameters (like user, host and"
		ewarn "password) into a dedicated file (/etc/bacula/my.cnf in this example) which"
		ewarn "can (and should!) be secured by simple filesystem access permissions."
		ewarn
		ewarn "See also:"
		ewarn "http://www.bacula.org/5.0.x-manuals/en/main/main/Bacula_Security_Issues.html"
		ewarn "http://www.bacula.org/5.0.x-manuals/en/main/main/Catalog_Maintenance.html#SECTION0043140000000000000000"
		ewarn
		ewarn "NOTICE:"
		ewarn "Since version 5.0.0 Bacula bundles an alternative catalog backup script"
		ewarn "installed as /usr/libexec/bacula/make_catalog_backup.pl that is not"
		ewarn "subject to this issue as it parses the director daemon config to extract"
		ewarn "the configured database connection parameters (including the password)."
		ewarn
		ewarn "*** ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ***"
		ewarn
		ebeep 10
		epause 20
		echo

		ewarn
		ewarn "Please note that SQLite v2 support as well as wxwindows (bwx-console)"
		ewarn "and gnome (gnome-console) support have been dropped from this release."
		ewarn
		ebeep 3
		epause 5
		echo
	fi

	ewarn
	ewarn "*** NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! ***"
	ewarn
	ewarn "Support for the bacula all-in-one init script has been removed from"
	ewarn "a prior release -- if you were previously using the all-in-one init"
	ewarn "script, please switch to using the individual init scripts now:"
	ewarn
	ewarn "- bacula-dir: bacula director       (for the central bacula server)"
	ewarn "- bacula-fd:  bacula file daemon    (for hosts to be backed up)"
	ewarn "- bacula-sd:  bacula storage daemon (for hosts storing the backup data)"
	ewarn
	ewarn "*** NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! ***"
	ewarn
	ebeep 5
	epause 10
}
