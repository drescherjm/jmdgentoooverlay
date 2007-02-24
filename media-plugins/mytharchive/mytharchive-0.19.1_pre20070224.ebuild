# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythnews/mythnews-0.19.ebuild,v 1.2 2006/02/12 10:34:40 cardoe Exp $

inherit mythtv-plugins eutils

DESCRIPTION="RSS feed news reading module for MythTV."
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/mythplugins-${PV}.tar.bz2
	http://www.mythtv.org/mc/mythtv-${PV}.tar.bz2"
IUSE="projectx"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="fetch"
RDEPEND="dev-python/imaging
	dev-python/mysql-python
        >=media-video/transcode-0.6.14
        >=media-video/dvdauthor-0.6.11
        >=media-gfx/imagemagick-6.0.6
        dev-db/mysql
        >=app-cdr/cdrtools-2.01
        media-video/ffmpeg
        >=app-cdr/dvd+rw-tools-5.21.4.10.8"

src_unpack()
{
  unpack ${A}
  cd ${S}/../mythtv-${PV}
  MY_VAR=`pwd`
  cd ${S}/mytharchive\
  
  if use projectx; then
    epatch "${FILESDIR}/mytharchive-0.19.1_pre20070101.mythburn.projectx.patch"
    epatch "${FILESDIR}/mytharchive-0.19.1_pre20070101.mythburn.projectx.archivesettings.patch"    
  fi

  pwd
  echo "SRC_PATH= '${MY_VAR}'" >> settings.pro
  ln -s ${MY_VAR}/libs mythtv
  cd mytharchive
  ln -s ${MY_VAR}/libs mythtv
}
