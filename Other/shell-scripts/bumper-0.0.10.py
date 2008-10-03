#!/usr/bin/env python

"""

NAME 
     bumper

DESCRIPTION
     "bumps up" a version of an ebuild, download file(s), and create a digest for it.
    
SYNOPSIS 
     bumper games-arcade/pacman-1.0 2.0


AUTHOR
     Rob Cakebread <pythonhead@gentoo.org>


EXAMPLE

    bumper games-arcade/pacman-0.0.1 0.0.2

    This will copy:
      /usr/portage/games-arcade/pacman/pacman-0.0.1
    to:
      /usr/local/portage/games-arcade/pacman/pacman-0.0.2

    creating the necessary directories, download file(s), create a digest for it.
    It also copies non-digest files from ${FILESDIR} but you'll have to rename those
    manually in the case of patches, if needed. 


TODO
    Make all in KEYWORDS ~arch

    i.e. if it had:
      KEYWORDS="x86 ppc sparc"
    change to:
      KEYWORDS="~x86 ~ppc ~sparc"


CHANGELOG

0.0.10 - Fixed makedirs

0.0.9 - If no digest created due to invalid SRC_URI offer to edit ebuild in ${EDITOR}
        If digest is created offer to emerge ebuild
        Lots of code cleanup

0.0.8 - Saner copying from ${FILESDIR} in case you use CVS instead of emerge sync
        More informative error checking/messages

0.0.7 - Don't clobber stuff in the overlay's $FILESDIR

0.0.6 - More error checking, fixed import portage error

0.0.5 - Now using gentoolkit.py 

0.0.4 - Changed delimiter for PORTDIR_OVERLAY from space to colon.
      - Copy non-digest files from ${FILESDIR}
      - More error checking for env vars, warn and exit if no
        PORTDIR_OVERLAY
      - Exits if user isn't root

"""


import os
import sys
import shutil
import commands

from output import *
from portage import config, settings

sys.path.insert(0, "/usr/lib/gentoolkit/pym/")
import gentoolkit

__version__="0.0.10"

if os.getuid() != 0:
    print red("You must be root to run bumper.")
    sys.exit(1)

if len(sys.argv) < 3:
    print red("\nI need a category/package to bump up and a destination version.\n")
    print green("Example:")
    print "bumper games-arcade/pacman-1.0 2.0\n" 
    sys.exit(1)

try:
    env = config(clone=settings).environ()
except:
    print "ERROR: Can't read portage configuration from /etc/make.conf"
    sys.exit(1)

try:
    #In case people have multiple PORTDIR_OVERLAY directories, use first one.
    # See http://bugs.gentoo.org/show_bug.cgi?id=10803
    PORTDIR_OVERLAY = env['PORTDIR_OVERLAY'].split(" ")[0]
except:
    print red("ERROR: You must define PORTDIR_OVERLAY in your /etc/make.conf")
    print green("You can simply uncomment this line:")
    print green("#PORTDIR_OVERLAY='/usr/local/portage'")
    print green("Then: mkdir -p /usr/local/portage")
    sys.exit(1)

def get_versions(query, new_version):
    cat, pn, version, rev = gentoolkit.split_package_name(query)
    try:
        pkg = gentoolkit.find_packages("=%s" % query)[0]
    except:
        print red("Error - Can't find ebuild for %s" % query)
        print green("\nGive the category and ebuild name in this format:")
        print "bumper games-arcade/pacman-0.1 0.2"
        sys.exit(1)

    if not pkg:
        print red("Error - Can't find ebuild for %s" % query)
        print green("\nGive the category and ebuild name in this format:")
        print "bumper games-arcade/pacman-0.1 0.2"
        sys.exit(1)

    ebuild_path = pkg.get_ebuild_path()
    filesdir = "%s/files" % pkg.get_package_path()
    # Is it an overlay version?
    overlay = pkg.is_overlay()
    if rev != "r0":
        version += "-" + rev
    dest = ("%s/%s/%s/%s-%s.ebuild" % \
           (PORTDIR_OVERLAY, cat, pn, pn, new_version))
    if os.path.exists(dest):
        print red("Error - Destination file exists:")
        print dest
        sys.exit(1)
    return ebuild_path, dest, cat, pn, filesdir, overlay

def copy_filesdir(filesdir, dest_filesdir):
    """Copy all non-digest files from source FILESDIR to dest FILESDIR"""
    for test_file in os.listdir(filesdir):
        if test_file != "CVS" and test_file[0:7] != 'digest-':
            source_file = "%s/%s" % (filesdir, test_file)
            dest_file = "%s/%s" % (dest_filesdir, test_file)
            try:
                if not os.path.exists(dest_file):
                    print green("))) Copying file: %s" % test_file)
                    shutil.copyfile(source_file, dest_file)
            except OSError, msg:
                print red("Failed copying file: %s to %s " % (source_file, dest_file))
                print red(msg)
                sys.exit(1)

def bump(orig, dest, filesdir, overlay):
    """ Copies original ebuild to new, copys $FILESDIR, creates digest"""
    #dest_filesdir = "%s/%s/%s/files" % (PORTDIR_OVERLAY, cat, pn)
    dest_filesdir = "%s/files" % os.path.dirname(dest)
    if not os.path.exists(dest_filesdir):
        os.makedirs(dest_filesdir)
    try:
        shutil.copyfile(orig, dest)
    except OSError, msg:
        print red("Couldn't copy file, aborting.")
        print red(msg)
        sys.exit(1)

    if not overlay: #only copy from portdir to overlay
        print "not overlay"
        copy_filesdir(filesdir, dest_filesdir)
    create_digest(dest)

def create_digest(dest):
    print "))) Creating digest..."
    status, output = commands.getstatusoutput("/usr/sbin/ebuild %s digest" % dest)
    if status: #if theres an error downloading, show full ebuild ___ digest output
        print output
    print blue(" *  Your new ebuild is here:\n %s" % dest)

def check_digest(dest, pn, new_version):
    dest_filesdir = "%s/files" % os.path.dirname(dest)
    digest = "%s/digest-%s-%s" % (dest_filesdir, pn, new_version)
    if not os.path.exists(digest):
        return -1

query = sys.argv[1]
new_version = sys.argv[2]
ebuild_path, dest, cat, pn, filesdir, overlay = get_versions(query, new_version)
bump(ebuild_path, dest, filesdir, overlay)

if check_digest(dest, pn, new_version) == -1:
    print red("Digest not created. Check SRC_URI in new ebuild.")
    print red("You may also want to verify the new version number is correct.")
    ed = os.getenv("EDITOR")
    msg = "Would you like to edit the ebuild with %s (y/n)?" %  ed
    k = raw_input(msg)
    if k == "y":
        os.system("%s %s" % (ed, dest))
else:
    msg = "Would you like to emerge the ebuild now?"
    k = raw_input(msg)
    if k == "y":
        os.system("emerge =%s/%s-%s" % (cat, pn, new_version))

