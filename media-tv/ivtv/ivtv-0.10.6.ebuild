# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/ivtv/ivtv-0.10.1-r1.ebuild,v 1.3 2007/04/27 01:43:45 beandog Exp $

inherit eutils linux-mod

DESCRIPTION="ivtv driver for Hauppauge PVR PCI cards"
HOMEPAGE="http://www.ivtvdriver.org"
SRC_URI="http://dl.ivtvdriver.org/ivtv/archive/0.10.x/${P}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 ppc x86"
IUSE="fbcon"
RDEPEND="|| ( >=sys-fs/udev-103 sys-apps/hotplug )"
DEPEND="app-arch/unzip"
PDEPEND="=media-tv/pvr-firmware-20070217"

pkg_setup() {

	MODULE_NAMES="ivtv(extra:${S}/driver)
			saa717x(extra:${S}/i2c-drivers)"
	BUILD_TARGETS="all"
	CONFIG_CHECK="EXPERIMENTAL KMOD VIDEO_DEV I2C VIDEO_V4L1_COMPAT VIDEO_V4L2
		!VIDEO_HELPER_CHIPS_AUTO
		FW_LOADER VIDEO_WM8775 VIDEO_MSP3400 VIDEO_CX25840 VIDEO_TUNER
		VIDEO_SAA711X VIDEO_CX2341X VIDEO_SAA7127 VIDEO_TVEEPROM"

	if use fbcon; then
		MODULE_NAMES="${MODULE_NAMES} ivtv-fb(extra:${S}/driver)"
		CONFIG_CHECK="${CONFIG_CHECK} FB FB_TRIDENT FRAMEBUFFER_CONSOLE FONTS"
	fi

	if ! ( kernel_is 2 6 18 || kernel_is 2 6 19 || kernel_is 2 6 20 ); then
		eerror "Each IVTV driver branch will only work with a specific"
		eerror "linux kernel branch."
		eerror ""
		eerror "You will need to either:"
		eerror "a) emerge a different kernel"
		eerror "b) emerge a different ivtv driver"
		eerror ""
		eerror "2.6.18 through 2.6.20, ivtv-0.10.0"
		eerror "2.6.19, ivtv 0.9"
		eerror "2.6.18, ivtv 0.8"
		eerror "2.6.17, ivtv 0.7"
		eerror "2.6.17, ivtv 0.7"
		eerror "2.6.16, ivtv 0.6"
		eerror "2.6.15, ivtv 0.4"
		eerror ""
		eerror "See http://ivtvdriver.org/ for more information"
		die "This only works on kernels 2.6.18 through 2.6.20"
	fi

	if kernel_is 2 6 20; then
		ewarn
		ewarn "For 2.6.20.x kernels, this module will *only* work against"
		ewarn "these versions:"
		ewarn ">=sys-kernel/gentoo-sources-2.6.20-r1"
		ewarn ">=sys-kernel/vanilla-sources.2.6.20.2"
		ewarn ""
		epause 5
	fi

	if use fbcon; then
		ewarn ""
		ewarn "From the README regarding framebuffer support:"
		ewarn ""
		ewarn "ivtv-fb now requires that you enable the following kernel config"
		ewarn "options: Go to 'Device drivers -> Graphics support'. Enable"
		ewarn "'Support for frame buffer devices'. Enable 'Trident support'"
		ewarn "(the Trident module itself is not required)."
		ewarn ""
		ewarn "To get working console output, keep going to 'Console display"
		ewarn "driver support', and enable 'Framebuffer Console support'."
		ewarn "Enable 'Select compiled-in fonts' & once that's done, you should"
		ewarn "have a list of fonts. Choose one. With the default OSD size,"
		ewarn "'VGA 8x16' gives 80x30(PAL) 80x25(NTSC)."
		ewarn ""
		ewarn "This ebuild checks for all the correct kernel config options for"
		ewarn "framebuffer use with the exception of choosing a font.  Be sure"
		ewarn "to pick one yourself!"
		ewarn ""
	fi

	linux-mod_pkg_setup

	BUILD_PARAMS="KDIR=${KV_DIR}"
}

src_unpack() {
   	unpack ${A}
    	cd "${S}"	
#	epatch "${FILESDIR}"/${P}-pio.patch
}

src_compile() {

	cd "${S}/driver"
	linux-mod_src_compile || die "failed to build driver"

	cd "${S}/utils"
	emake INCDIR="${KV_DIR}/include" || die "failed to build utils "
}

src_install() {
	cd "${S}/utils"
	make DESTDIR="${D}" PREFIX="/usr" install || die "failed to install utils"
	dobin perl/*.pl

	cd "${S}"
	dodoc README* doc/* utils/README.X11 ChangeLog* utils/perl/README.ptune

	cd "${S}/driver"
	linux-mod_src_install || die "failed to install modules"

	# Add the aliases
	insinto /etc/modules.d
	newins "${FILESDIR}"/ivtv ivtv
}

pkg_postinst() {

	linux-mod_pkg_postinst

	elog ""
	elog "This version of the IVTV driver supports the following hardware:"
	elog "Hauppauge WinTV PVR-250"
	elog "Hauppauge WinTV PVR-350"
	elog "Hauppauge WinTV PVR-150"
	elog "Hauppauge WinTV PVR-500"
	elog "AVerMedia M179"
	elog "Yuan MPG600/Kuroutoshikou iTVC16-STVLP"
	elog "Yuan MPG160/Kuroutoshikou iTVC15-STVLP"
	elog "Yuan PG600/DiamondMM PVR-550 (CX Falcon 2)"
	elog "Adaptec AVC-2410"
	elog "Adaptec AVC-2010"
	elog "Nagase Transgear 5000TV"
	elog "AOpen VA2000MAX-STN6"
	elog "Yuan MPG600GR/Kuroutoshikou CX23416GYC-STVLP"
	elog "I/O Data GV-MVP/RX"
	elog "I/O Data GV-MVP/RX2E"
	elog "Gotview PCI DVD (preliminary support only)"
	elog "Gotview PCI DVD2 Deluxe"
	elog "Yuan MPC622"
	elog ""
	ewarn ""
	ewarn "IMPORTANT: In case of problems first read this page:"
	ewarn "http://www.ivtvdriver.org/index.php/Troubleshooting"
	ewarn ""
	ewarn "If any of these conditions match your setup, you may want to look at the"
	ewarn "README in /usr/share/doc/${PF}/"
	ewarn ""
	ewarn " - Using MythTV, a PVR-350 and the ivtv-fb module"
	ewarn " - Using the ivtv X driver and the ivtv-fb module"
	ewarn " - You want to manually build ivtv against v4l-dvb"
	ewarn ""
	ewarn "Also, the ivtv package comes with lots of documentation regarding setup,"
	ewarn "proper use and debugging utilities."
	ewarn "They are also located in /usr/share/doc/${PF}/"
	ewarn ""
	ewarn "For more information, see the IVTV driver homepage at:"
	ewarn "http://www.ivtvdriver.org/"
}
