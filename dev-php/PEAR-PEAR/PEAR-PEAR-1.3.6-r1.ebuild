# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/www.gentoo.org/raw_cvs/gentoo-x86/dev-php/PEAR-PEAR/Attic/PEAR-PEAR-1.3.6-r1.ebuild,v 1.6 2006/01/09 14:15:37 sebastian dead $

inherit depend.php

ARCHIVE_TAR="1.3.1"
CONSOLE_GETOPT="1.2"
PEAR="1.3.6"
XML_RPC="1.4.3"

[ -z "${PEAR_CACHEDIR}" ] && PEAR_CACHEDIR=/tmp/pear/cache

DESCRIPTION="PEAR Base System"
HOMEPAGE="http://pear.php.net/"
SRC_URI="http://pear.php.net/get/Archive_Tar-${ARCHIVE_TAR}.tgz
		http://pear.php.net/get/Console_Getopt-${CONSOLE_GETOPT}.tgz
		http://pear.php.net/get/XML_RPC-${XML_RPC}.tgz
		http://pear.php.net/get/PEAR-${PEAR}.tgz"

LICENSE="PHP"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86"
IUSE=""

# we deliberately force people to remove their old PEAR installations,
# and any package which may have put an old-style PEAR installation onto
# the box

DEPEND="dev-lang/php
		!dev-php/php
		!dev-php/php-cgi
		!dev-php/mod_php
		!<=dev-php/PEAR-PEAR-1.3.5-r1"

PDEPEND=">=dev-php/PEAR-Archive_Tar-1.3.1-r1
		>=dev-php/PEAR-Console_Getopt-1.2-r1
		>=dev-php/PEAR-XML_RPC-1.4.3"

pkg_setup() {
	# we call this here, to ensure that the eclass picks the right
	# version of php for the job
	require_php_cli

	# we check that PHP was compiled with the correct USE flags
	require_php_with_use pear
}

src_install() {
	require_php_cli

	# Prevent SNMP related sandbox violoation.
	addpredict /usr/share/snmp/mibs/.index
	addpredict /var/lib/net-snmp/

	if [[ -d "${ROOT}"/usr/bin/pear ]] ; then
		install_pear_without_bootstrap
	else
		bootstrap_pear
		install_pear_after_bootstrap
	fi

	keepdir "${PEAR_CACHEDIR}"
	fperms 755 "${PEAR_CACHEDIR}"
}

pkg_postinst() {
	if has_version "<${PV}"; then
		ewarn "The location of the local PEAR repository has been changed"
		ewarn "from /usr/lib/php to /usr/share/php."
	fi
}

bootstrap_pear() {
	mkdir -p "${WORKDIR}/PEAR/XML/RPC"

	# Install PEAR Package.
	cp -r "${WORKDIR}/PEAR-${PEAR}/OS" "${WORKDIR}/PEAR/"
	cp -r "${WORKDIR}/PEAR-${PEAR}/PEAR" "${WORKDIR}/PEAR/"
	cp "${WORKDIR}/PEAR-${PEAR}/PEAR.php" "${WORKDIR}/PEAR/PEAR.php"
	cp "${WORKDIR}/PEAR-${PEAR}/System.php" "${WORKDIR}/PEAR/System.php"

	# Prepare /usr/bin/pear script.
	cp "${WORKDIR}/PEAR-${PEAR}/scripts/pearcmd.php" "${WORKDIR}/PEAR/pearcmd.php"
	cp "${WORKDIR}/PEAR-${PEAR}/scripts/pear.sh" "${WORKDIR}/PEAR/pear"
	sed -i "s:@php_bin@:${PHPCLI}:g" "${WORKDIR}/PEAR/pear" || die
	sed -i "s:@bin_dir@:/usr/bin:g" "${WORKDIR}/PEAR/pear" || die
	sed -i 's:@php_dir@:/usr/share/php:g' "${WORKDIR}/PEAR/pear" || die

	# Install Archive_Tar Package.
	cp -r "${WORKDIR}/Archive_Tar-${ARCHIVE_TAR}/Archive" "${WORKDIR}/PEAR/Archive"

	# Install Console_Getopt Package.
	cp -r "${WORKDIR}/Console_Getopt-${CONSOLE_GETOPT}/Console" "${WORKDIR}/PEAR/"

	# Install XML_RPC Package.
	cp "${WORKDIR}/XML_RPC-${XML_RPC}/RPC.php" "${WORKDIR}/PEAR/XML/RPC.php"
	cp "${WORKDIR}/XML_RPC-${XML_RPC}/Server.php" "${WORKDIR}/PEAR/XML/RPC/Server.php"

	# Finalize installation.
	cd "${WORKDIR}/PEAR"
	insinto /usr/share/php
	doins -r Archive Console OS PEAR XML *.php
	dobin pear
}

install_pear_after_bootstrap() {
	${PHPCLI} -d include_path=".:${D}/usr/share/php" "${D}/usr/share/php/pearcmd.php" config-set doc_dir /usr/share/php/doc || die
	${PHPCLI} -d include_path=".:${D}/usr/share/php" "${D}/usr/share/php/pearcmd.php" config-set data_dir /usr/share/php/data || die
	${PHPCLI} -d include_path=".:${D}/usr/share/php" "${D}/usr/share/php/pearcmd.php" config-set test_dir /usr/share/php/test || die
	${PHPCLI} -d include_path=".:${D}/usr/share/php" "${D}/usr/share/php/pearcmd.php" config-set php_dir /usr/share/php || die
	${PHPCLI} -d include_path=".:${D}/usr/share/php" "${D}/usr/share/php/pearcmd.php" config-set bin_dir /usr/bin || die
	${PHPCLI} -d include_path=".:${D}/usr/share/php" "${D}/usr/share/php/pearcmd.php" config-set php_bin ${PHPCLI} || die

	mkdir "${D}/etc"
	cp "${HOME}/.pearrc" "${D}/etc/pear.conf"

	prepare_pear_install
	${PHPCLI} -d include_path=".:${D}/usr/share/php" "${D}/usr/share/php/pearcmd.php" install --nodeps --installroot="${D}" package.xml || die
}

install_pear_without_bootstrap() {
	prepare_pear_install
	PHP_PEAR_PHP_BIN=${PHPCLI} pear install --nodeps --installroot="${D}" package.xml || die
}

prepare_pear_install() {
	cp "${WORKDIR}/package.xml" "${WORKDIR}/PEAR-${PEAR}"
	cd "${WORKDIR}/PEAR-${PEAR}"
}

