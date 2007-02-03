# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/kdirstat/kdirstat-2.4.3.ebuild,v 1.5 2005/08/28 12:24:10 blubb Exp $

inherit kde eutils

DESCRIPTION="KDirStat - nice KDE replacement to du command"
HOMEPAGE="http://kdirstat.sourceforge.net/"
SRC_URI="http://kdirstat.sourceforge.net/download/${P}.tar.bz2"
#SRC_URI="mirror://sourceforge/kdirstat/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
KEYWORDS="amd64 ppc sparc x86"

IUSE=""
SLOT="0"

need-kde 3
