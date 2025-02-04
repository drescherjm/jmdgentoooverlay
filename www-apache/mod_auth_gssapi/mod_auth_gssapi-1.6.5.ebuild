# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit apache-module eutils systemd

DESCRIPTION="GSSAPI authentication for Apache"
HOMEPAGE="https://github.com/gssapi/mod_auth_gssapi"
SRC_URI="https://github.com/gssapi/mod_auth_gssapi/releases/download/v${PV}/${PF}.tar.gz"

LICENSE="Apache-2.0"
KEYWORDS="amd64"
SLOT="0"
IUSE="+apache2"
REQUIRED_USE="apache2"

APACHE2_MOD_DEFINE="AUTH_GSSAPI"
APACHE2_MOD_CONF="11_${PN}"
DOCFILES=( README )

DEPEND="virtual/krb5 www-servers/apache"
RDEPEND="${DEPEND}"

need_apache2

src_configure() {
	econf
}

src_compile() {
	#apache-module_src_compile does not work here
	emake
}

src_install() {
	#apache-module_src_install does not work here
	emake DESTDIR="${D}" install
	insinto "${APACHE_MODULES_CONFDIR}"
	newins "${FILESDIR}/${APACHE2_MOD_CONF}.conf" "${APACHE2_MOD_CONF}.conf"
	dodoc ${DOCFILES}
	systemd_dotmpfilesd "${FILESDIR}/${PN}.conf"
}
