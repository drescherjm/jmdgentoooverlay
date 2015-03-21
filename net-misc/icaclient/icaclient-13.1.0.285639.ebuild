# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit multilib eutils versionator

DESCRIPTION="ICA Client for Citrix Presentation servers"
HOMEPAGE="http://www.citrix.com/"
SRC_URI="amd64? ( linuxx64-${PV}.tar.gz )
	x86? ( linuxx86-${PV}.tar.gz )"

LICENSE="icaclient"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="nsplugin linguas_de linguas_es linguas_fr linguas_ja linguas_zh_CN"
RESTRICT="mirror strip userpriv fetch"

ICAROOT="/opt/Citrix/ICAClient"

QA_TEXTRELS="opt/Citrix/ICAClient/VDSCARD.DLL
	opt/Citrix/ICAClient/TW1.DLL
	opt/Citrix/ICAClient/NDS.DLL
	opt/Citrix/ICAClient/CHARICONV.DLL
	opt/Citrix/ICAClient/PDCRYPT1.DLL
	opt/Citrix/ICAClient/VDCM.DLL
	opt/Citrix/ICAClient/libctxssl.so
	opt/Citrix/ICAClient/PDCRYPT2.DLL
	opt/Citrix/ICAClient/npica.so
	opt/Citrix/ICAClient/VDSPMIKE.DLL
	opt/Citrix/ICAClient/VDFLASH2.DLL
	opt/Citrix/ICAClient/lib/libavutil.so
	opt/Citrix/ICAClient/lib/libavcodec.so
	opt/Citrix/ICAClient/lib/libavformat.so
	opt/Citrix/ICAClient/lib/libswscale.so"

QA_EXECSTACK="opt/Citrix/ICAClient/wfica
	opt/Citrix/ICAClient/libctxssl.so"

RDEPEND="x11-terms/xterm
	media-fonts/font-adobe-100dpi
	media-fonts/font-misc-misc
	media-fonts/font-cursor-misc
	media-fonts/font-xfree86-type1
	media-fonts/font-misc-ethiopic
	media-libs/gst-plugins-base
	media-libs/gstreamer
	dev-libs/atk
	dev-libs/glib
	dev-libs/libxml2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libogg
	media-libs/libpng:1.2
	media-libs/libvorbis
	media-libs/speex
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXaw
	x11-libs/libXext
	x11-libs/libXinerama
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/pango"

DEPEND=""

if use amd64 ; then
       ICAARCH=linuxx64
else
       ICAARCH=linuxx86
fi
S="${WORKDIR}/${ICAARCH}/${ICAARCH}.cor"

pkg_nofetch() {
	elog "Download the client file ${A} from
	https://www.citrix.com/downloads/citrix-receiver/linux/receiver-for-linux-131.html"
	elog "and place it in ${DISTDIR:-/usr/portage/distfiles}."
}

src_install() {
	dodir "${ICAROOT}"

	exeinto "${ICAROOT}"
	doexe *.DLL libctxssl.so libproxy.so wfica AuthManagerDaemon PrimaryAuthManager selfservice ServiceRecord

	exeinto "${ICAROOT}"/lib
	doexe lib/*.so

	exeinto "${ICAROOT}"
	if use nsplugin
	then
		doexe npica.so
		dosym "${ICAROOT}"/npica.so /usr/$(get_libdir)/nsbrowser/plugins/npica.so
	fi

	insinto "${ICAROOT}"
	doins nls/en/eula.txt

	insinto "${ICAROOT}"/config
	doins config/* config/.* nls/en/*.ini

	insinto "${ICAROOT}"/gtk
	doins gtk/*

	insinto "${ICAROOT}"/gtk/glade
	doins gtk/glade/*

	dodir "${ICAROOT}"/help

	insinto "${ICAROOT}"/config/usertemplate
	doins config/usertemplate/*

	LANGCODES="en"
	use linguas_de && LANGCODES+=" de"
	use linguas_es && LANGCODES+=" es"
	use linguas_fr && LANGCODES+=" fr"
	use linguas_ja && LANGCODES+=" ja"
	use linguas_zh_CN && LANGCODES+=" zh_CN"

	for lang in ${LANGCODES} ; do
		insinto "${ICAROOT}"/nls/${lang}
		doins nls/${lang}/*

		insinto "${ICAROOT}"/nls/$lang/UTF-8
		doins nls/${lang}.UTF-8/*

		insinto "${ICAROOT}"/nls/${lang}/LC_MESSAGES
		doins nls/${lang}/LC_MESSAGES/*

		insinto "${ICAROOT}"/nls/${lang}
		dosym UTF-8 "${ICAROOT}"/nls/${lang}/utf8
	done

	insinto "${ICAROOT}"/nls
	dosym en /opt/Citrix/ICAClient/nls/C

	insinto "${ICAROOT}"/icons
	doins icons/*

	insinto "${ICAROOT}"/keyboard
	doins keyboard/*

	rm -rf "${S}"/keystore/cacerts
	dosym /etc/ssl/certs "${ICAROOT}"/keystore/cacerts

	insinto "${ICAROOT}"/util
	doins util/pac.js

	exeinto "${ICAROOT}"/util
	doexe util/{configmgr,conncenter,echo_cmd,gst_aud_play,gst_aud_read,gst_play,gst_read,hdxcheck.sh,icalicense.sh,libgstflatstm.so}
	doexe util/{lurdump,new_store,nslaunch,pacexec,pnabrowse,sunraymac.sh,what,xcapture}

	doenvd "${FILESDIR}"/10ICAClient

	make_wrapper wfica "${ICAROOT}"/wfica . "${ICAROOT}"

	dodir /etc/revdep-rebuild/
	echo "SEARCH_DIRS_MASK=\"${ICAROOT}\"" > "${D}"/etc/revdep-rebuild/70icaclient
}


pkg_preinst() {
	local old_plugin="/usr/lib64/nsbrowser/plugins/npwrapper.npica.so"
	if use amd64 && [[ -f ${old_plugin} ]] ; then
		local wrapper="/usr/bin/nspluginwrapper"
		if [[ -x ${wrapper} ]] ; then
			einfo "Removing npica.so from wrapper."
			${wrapper} -r ${old_plugin}
		fi
	fi
}
