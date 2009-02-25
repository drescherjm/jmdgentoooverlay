# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools wxwidgets subversion flag-o-matic eutils

MY_PV="${PV%_*}"
SVNREV="${PV##*_pre}"

ESVN_OPTIONS="-r ${SVNREV}"

ESVN_CO_DIR="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}"/svn-src/${P/-svn}/"${ESVN_REPO_URI##*/}"

ESVN_REPO_URI="svn://svn.berlios.de/codeblocks/trunk"
ESVN_PROJECT="${P}"

WX_GTK_VER="2.8"

DESCRIPTION="free cross-platform C/C++ IDE"
HOMEPAGE="http://www.codeblocks.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="contrib unicode debug"

RDEPEND="=x11-libs/wxGTK-${WX_GTK_VER}*
   x11-libs/gtk+
   !dev-util/codeblocks
   !dev-util/codeblocks-cvs"

DEPEND="${RDEPEND}
   >=sys-devel/autoconf-2.5
   >=sys-devel/automake-1.7
   >=sys-devel/libtool-1.4
   app-arch/zip"

src_unpack() {
        subversion_src_unpack

        use vanilla || \
        EPATCH_SOURCE="${FILESDIR}/patches" \
        EPATCH_SUFFIX="patch" \
        EPATCH_ARCH="all" \
#        epatch
#        sed -i -e "s:\$(top_srcdir):${ESVN_CO_DIR}:" src/tools/autorevision/Makefile.am

       sed -i -e "s:\$(top_srcdir):${ESVN_CO_DIR}:" ${S}/src/build_tools/autorevision/Makefile.am

       REV_FILE_M4=./revision.m4
       CB_REV=0
       CB_REV=`LC_ALL=C svn info "${ESVN_CO_DIR}" | grep Revision: | cut -d" " -f2`;
       echo "m4_define([SVN_REVISION], trunk-r${CB_REV})" > ${S}/$REV_FILE_M4 
} 

src_compile() {
   export WANT_AUTOCONF=2.5
   export WANT_AUTOMAKE=1.7

   local TMP

   TMP="/usr/share/aclocal/libtool.m4"
   einfo "Running ./bootstrap"
   if [ -e "$TMP" ]; then
      cp "$TMP" aclocal.m4 || die "cp failed"
   fi
   ./bootstrap || die "boostrap failed"

   econf --with-wx-config="${WX_CONFIG}" \
      $(use_enable contrib) \
      $(use_enable debug) \
      || die "econf failed"

   emake || die "emake failed"
}

src_install() {
   make install DESTDIR="${D}" || die "make install failed"
} 
