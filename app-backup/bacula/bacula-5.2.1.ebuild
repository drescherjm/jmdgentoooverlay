# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/bacula/bacula-5.0.3-r3.ebuild,v 1.3 2011/05/14 09:28:46 tomjbe Exp $

EAPI="2"
PYTHON_DEPEND="python? 2"
PYTHON_USE_WITH="threads"
PYTHON_USE_WITH_OPT="python"

inherit eutils multilib python

MY_PV=${PV/_beta/-b}
MY_P=${PN}-${MY_PV}
#DOC_VER="${MY_PV}"

DESCRIPTION="Featureful client/server network backup suite"
HOMEPAGE="http://www.bacula.org/"

#DOC_SRC_URI="mirror://sourceforge/bacula/${PN}-docs-${DOC_VER}.tar.bz2"
SRC_URI="mirror://sourceforge/bacula/${MY_P}.tar.gz"
#		doc? ( ${DOC_SRC_URI} )

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc ~sparc ~x86"
IUSE="bacula-clientonly bacula-nodir bacula-nosd ipv6 logwatch mysql postgres python qt4 readline +sqlite3 ssl static tcpd vim-syntax X"

# maintainer comment:
# postgresql-base should have USE=threads (see bug 326333) but fails to build
# atm with it (see bug #300964)
DEPEND="
	>=sys-libs/zlib-1.1.4
	dev-libs/gmp
	!bacula-clientonly? (
		postgres? ( dev-db/postgresql-base[threads] )
		mysql? ( virtual/mysql )
		sqlite3? ( dev-db/sqlite:3 )
		!bacula-nodir? ( virtual/mta )
	)
	qt4? (
		x11-libs/qt-svg:4
		x11-libs/qwt:5
	)
	ssl? ( dev-libs/openssl )
	logwatch? ( sys-apps/logwatch )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	readline? ( >=sys-libs/readline-4.1 )
	sys-libs/ncurses"
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
	)
	vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )"

S=${WORKDIR}/${MY_P}

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
			ewarn
			ewarn "No database backend selected, defaulting to sqlite3."
			ewarn "Supported databases are mysql, postgresql, sqlite3"
			ewarn
			export mydbtype=sqlite3
		elif [[ "${dbnum}" -gt 1 ]]; then
			ewarn
			ewarn "Too many database backends selected, defaulting to sqlite3."
			ewarn "Supported databases are mysql, postgresql, sqlite3"
			ewarn
			export mydbtype=sqlite3
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

	if use bacula-clientonly && use static && use qt4; then
		ewarn
		ewarn "Building statically linked 'bat' is not supported. Ignorig 'qt4' useflag."
		ewarn
	fi

	if ! use bacula-clientonly; then
		# USE=static only supported for bacula-clientonly
		if use static; then
			ewarn
			ewarn "USE=static only supported together with USE=bacula-clientonly."
			ewarn "Ignoring 'static' useflag."
			ewarn
		fi
		if [ -z "$(egetent passwd bacula 2>/dev/null)" ]; then
			enewuser bacula -1 -1 /var/lib/bacula bacula,disk,tape,cdrom,cdrw || die
			einfo
			einfo "The user 'bacula' has been created.  Please see the bacula manual"
			einfo "for information about running bacula as a non-root user."
			einfo
		fi
	fi

	if use python; then
		python_set_active_version 2
		python_pkg_setup
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

	# drop automatic install of unneeded documentation (for bug 356499)
	epatch "${FILESDIR}"/${PV}/${P}-doc.patch

	# bug #310087
	#epatch "${FILESDIR}"/${PV}/${P}-as-needed.patch

	# bug #311161
	epatch "${FILESDIR}"/${PV}/${P}-lib-search-path.patch

	# stop build for errors in subdirs
	epatch "${FILESDIR}"/${PV}/${P}-Makefile.patch

	# bat needs to respect LDFLAGS
	epatch "${FILESDIR}"/${PV}/${P}-ldflags.patch

	# bug #328701
	epatch "${FILESDIR}"/${PV}/${P}-openssl-1.patch

	#epatch "${FILESDIR}"/${PV}/${P}-fix-static.patch
}

src_configure() {
	local myconf=''

	if use bacula-clientonly; then
		myconf="${myconf} \
			$(use_enable bacula-clientonly client-only) \
			$(use_enable !static libtool) \
			$(use_enable static static-cons) \
			$(use_enable static static-fd)"
	else
		myconf="${myconf} \
			$(use_enable !bacula-nodir build-dird) \
			$(use_enable !bacula-nosd build-stored)"
		# bug #311099
		# database support needed by dir-only *and* sd-only
		# build as well (for building bscan, btape, etc.)
		myconf="${myconf} \
			--with-${mydbtype} \
			--enable-batch-insert"
	fi

	# do not build bat if 'static' clientonly
	if ! use bacula-clientonly || ! use static; then
		myconf="${myconf} \
			$(use_enable qt4 bat)"
	fi

	myconf="${myconf} \
		--disable-tray-monitor \
		$(use_with X x) \
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
		${myconf}
}

src_compile() {
	emake || die "emake failed"

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
	insinto /usr/share/pixmaps
	doins scripts/bacula.png || die

	# install bat when enabled (for some reason ./configure doesn't pick this up)
	if use qt4 && ! use static ; then
		dosbin "${S}"/src/qt-console/.libs/bat || die
		insinto /usr/share/pixmaps
		doins src/qt-console/images/bat_icon.png || die
		insinto /usr/share/applications
		doins scripts/bat.desktop || die
	fi

	# remove some scripts we don't need at all
	rm -f "${D}"/usr/libexec/bacula/{bacula,bacula-ctl-dir,bacula-ctl-fd,bacula-ctl-sd,startmysql,stopmysql}

	# rename statically linked apps
	if use bacula-clientonly && use static ; then
		pushd "${D}"/usr/sbin || die
		mv static-bacula-fd bacula-fd || die
		mv static-bconsole bconsole || die
		popd || die
	fi

	# extra files which 'make install' doesn't cover
	if ! use bacula-clientonly; then
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

	rm -vf "${D}"/usr/share/man/man1/bacula-bwxconsole.1*
	if ! use qt4; then
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
	dodoc ChangeLog LICENSE ReleaseNotes SUPPORT technotes

	# vim-files
	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/syntax
		doins scripts/bacula.vim || die
		insinto /usr/share/vim/vimfiles/ftdetect
		newins scripts/filetype.vim bacula_ft.vim || die
	fi

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
		cp "${FILESDIR}/${script}".confd "${T}/${script}".confd || die "failed to copy ${script}.confd"
		cp "${FILESDIR}/${script}".initd "${T}/${script}".initd || die "failed to copy ${script}.initd"
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
		ewarn "user on the system"
		ewarn
		ewarn "NOTICE:"
		ewarn "Since version 5.0.0 Bacula bundles an alternative catalog backup script"
		ewarn "installed as /usr/libexec/bacula/make_catalog_backup.pl that is not"
		ewarn "subject to this issue as it parses the director daemon config to extract"
		ewarn "the configured database connection parameters (including the password)."
		ewarn
		ewarn "See also:"
		ewarn "http://www.bacula.org/5.0.x-manuals/en/main/main/Bacula_Security_Issues.html"
		ewarn "http://www.bacula.org/5.0.x-manuals/en/main/main/Catalog_Maintenance.html#SECTION0043140000000000000000"
		ewarn
		ewarn "*** ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ***"
		ewarn
		ebeep 5
		epause 10
		echo

		einfo
		einfo "Please note that SQLite v2 support as well as wxwindows (bwx-console)"
		einfo "and gnome (gnome-console) support have been dropped."
		einfo
	fi

	einfo "Please note that 'bconsole' will always be installed. To compile 'bat'"
	einfo "you have to enable 'USE=qt4'."
	einfo
}
