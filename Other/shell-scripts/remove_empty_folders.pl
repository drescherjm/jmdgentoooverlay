#!/usr/bin/perl 

use File::Find; 

finddepth(sub{rmdir},'.')
