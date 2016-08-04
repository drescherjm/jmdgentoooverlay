#!/usr/bin/perl -w
#

use strict;

use File::Slurp qw(slurp);

my $ifile = slurp($ARGV[0], binmode=> ':raw');
my $newfile;
my $i=1;
my @newfiles = split(/TRAILER!!!/,$ifile);
`mkdir $ARGV[0].dir`;

foreach $newfile (@newfiles)
{
        open F, "> ./$ARGV[0].dir/$i";
        print F $newfile;
        print F "TRAILER!!!\0";
        close F;
        `cd $ARGV[0].dir; cpio -i -H newc < $i; rm $i; cd ..`;
        $i++;
}

