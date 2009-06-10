# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythweather/mythweather-0.21_p17719.ebuild,v 1.4 2008/12/23 17:27:25 maekke Exp $

inherit mythtv-plugins subversion

DESCRIPTION="Weather forecast module for MythTV."
IUSE=""
KEYWORDS="amd64 ppc x86"

DEPEND="dev-perl/DateManip
	dev-perl/ImageSize
	dev-perl/SOAP-Lite
	dev-perl/XML-Simple
	dev-perl/XML-Parser
	dev-perl/XML-SAX"
