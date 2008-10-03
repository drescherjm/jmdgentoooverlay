#! /usr/bin/perl -w
#
# Generate a script which when run recompiles each and every package
# in the Gentoo system.
# This will typically be required on a major GCC upgrade.
#
# $HeadURL: /caches/xsvn/trunk/usr/local/sbin/recompile-entire-system $
# $Author: root $
# $Date: 2006-09-26T04:22:55.640944Z $
# $Revision: 390 $
#
# Written in 2006 by Guenther Brunthaler


use strict;
use File::Temp ':POSIX';


# Change this to any name you like.
my $script= "recompile-remaining-packages";


my $script_header= << '.';
#!/bin/bash
#
# Run this script repeatedly (if interrupted)
# until no more packages will be compiled.
#
# $Date: 2006-09-26T04:22:55.640944Z $
# $Revision: 390 $
# Written in 2006 by Guenther Brunthaler


SCRIPT_VERSION="1.13"


die() {
	echo "ERROR: $*" >& 2; exit 1
}

RM() {
	rm "$1" || die "Could not remove file '$1': $!!"
}

MV() {
	mv "$1" "$2" || die "Could not rename file '$1' into '$2': $!!"
}

CHMOD() {
	chmod $* || die "Could not set permissions 'chmod $*': $!!"
}

save_progress() {
	{
		echo "$VERSION"; echo "$OURGCC"
		echo "$PROGRESS $OK $FAILED"
	} > "$STATE_FILE"
}

item() {
	test "$PROGRESS" -ge "$1" && return
	echo "Emerging package # $1 ('$2')..."
	local RC; emerge -k --oneshot --nodeps "$2"; RC=$?
	if [ $RC = 0 ]; then
		echo "Package # $1 rebuild complete."
		(( ++OK ))
	elif [ $RC -gt 100 ]; then
		echo "Emerge failed return code $?. Aborting on user request."
		exit 1
	else
		echo "Emerge failed return code $? (will be retried later)."
		(( ++FAILED ))
		echo "$2" >> "$FAILURES_FILE"
	fi
	echo; PROGRESS="$1"; save_progress
}


BASENAME="${0##*/}"
STATE_FILE="$HOME/.$BASENAME.state"
FAILURES_FILE="$HOME/.$BASENAME.failures"
LOG_FILE="$HOME/${BASENAME}_$(date '+%Y-%m-%dT%T').log"
REPEAT="--4ydzd3yuhmsynbjr644bbfzx5"
if [ "$1" != "$REPEAT" ]; then
	exec > >(
		echo "Note: Logging to file '$LOG_FILE'."
		tee "$LOG_FILE"
		echo
		echo "Note: A log has been written to '$LOG_FILE'."
	)
fi
OURGCC="`gcc-config --get-current-profile`" || die "gcc-config failed!"
VERSION=; LASTGCC=; PROGRESS=; OK=; FAILED=
{
	read VERSION; read LASTGCC; read PROGRESS OK FAILED
}  2> /dev/null < "$STATE_FILE"
if [ "$VERSION" != "$SCRIPT_VERSION" -o "$OURGCC" != "$LASTGCC" ]; then
	VERSION="$SCRIPT_VERSION"; true > "$FAILURES_FILE"
	PROGRESS=0; OK=0; FAILED=0; save_progress
fi

# Now the list of packages to be recompiled follows.
.

my $script_tail= << '.';
# End of package list.

echo
if [ $FAILED = 0 ]; then
	echo "Success! All packages have been re-compiled."
	echo "Your system is now up-to-date with respect to $OURGCC!"
elif [ $OK = 0 ]; then
	echo "Giving up: Could not compile any more packages in the current"
	echo "recompilation phase."
	echo "Look into the 'item'-lines of script '$0'"
	echo "to see which packages could not be recompiled."
else
	echo "Partial success: The current recompilation phase has"
	echo "finished."
	echo
	echo "However, $FAILED packages were not compiled successfully"
	echo "in this phase."
	echo
	echo "Therefore, another phase will be started now, where an attempt"
	echo "will be made to recompile the remaining packages."
	echo
	echo "Note that this will *not* lead into an infinite loop:"
	echo "In the last phase $OK packages have been compiled"
	echo "successfully, and thus the total number of remaining"
	echo "packages has been diminished already."
	echo
	ME="$0"
	if [ ! -e "$ME" ]; then
		ME="$(which "$ME")"
		test -e "$ME" || die "Cannot locate '$0'"
	fi
	NEW="${ME}_$$.tmp"
	(
		IFS=$'\n'
		while read -r LINE; do
			test "$LINE" != "${LINE#item }" && break
			echo "$LINE"
		done
		{
			while read -r LINE; do
				echo "item $(( ++PROGRESS )) $LINE"
			done
		} < "$FAILURES_FILE"
		while read -r LINE; do
			if [ "$LINE" = "${LINE#item }" ]; then
				echo "$LINE"
				break
			fi
		done
		while read -r LINE; do echo "$LINE"; done
	) < "$ME" > "$NEW"
	CHMOD --reference="$ME" "$NEW"; RM "$ME"; MV "$NEW" "$ME"
	VERSION="NONE"; save_progress
	exec "$ME" "$REPEAT"
fi
RM "$FAILURES_FILE"; RM "$STATE_FILE"
.


# Remove the largest common whitespace prefix from all lines
# of the first argument.
# (Empty lines or lines containing only whitespace are skipped
# by this operation and will be replaced by
# completely empty lines.)
# The first argument must either be a reference to a multiline
# string containing newline characters or a reference to an
# array of single line strings (without newline characters).
# Then optionally indent all resulting lines with the prefix
# specified as the argument to the -first option.
# For all indented lines do the same, but use the argument
# to option -indent as the value of the -first option then.
# If option -wrap <number> is specified, contiguous non-empty
# lines of the same indentation depth are considered paragraphs,
# and will be word-wrapped on output, resulting in a maximum
# total line length of <number> characters.
# The word-wrappin will occur on whitespaces, which can be
# protected by a backslash.
sub normalize_indentation {
   my($tref, %opt)= @_;
   my(@t, $t, $p, $pl);
   $opt{-first}||= '';
   $opt{-indent}||= ' ';
   $t= ref($tref) eq 'ARRAY' ? $tref : [split /\n/, $$tref];
   foreach (@$t) {
      s/^\s+$//;
      next if $_ eq '';
      if (defined $pl) {
         for (;;) {
            substr($p, $pl= length)= '' if length() < $pl;
            last if substr($_, 0, $pl) eq $p;
            substr($p, --$pl)= '';
         }
      } else {
         ($p)= /^(\s*)/;
         $pl= length $p;
      }
   }
   substr($_, 0, $pl)= '' foreach grep $_ ne '', @$t;
   if (exists $opt{-wrap}) {
      my $width= $opt{-wrap} - length $opt{-first};
      my $i;
      my $wrap= sub {
         my($tref, $aref, $iref, $w)= @_;
         my $buf;
         my $insert= sub {
            my($tref, $aref, $iref)= @_;
            splice @$aref, $$iref++, 0, $$tref if defined $$tref;
            undef $$tref;
         };
         return unless $$tref;
         foreach (split /(?:(?<!\\)\s)+/, $$tref) {
            s/\\\s/ /gs;
            if (length($buf || '') + length > $w) {
               &$insert(\$buf, $aref, $iref);
            }
            if (defined $buf) {$buf.= " $_"} else {$buf= $_}
         }
         &$insert(\$buf, $aref, $iref);
         undef $$tref;
      };
      $width= 1 if $width < 1;
      undef $p;
      for ($i= 0; $i < @$t; ) {
         if ($t->[$i] =~ /^(?:\s|$)/) {
            &$wrap(\$p, $t, \$i, $width);
            ++$i;
         } else {
            if (defined $p) {$p.= ' '} else {$p= ''}
            $p.= $t->[$i];
            splice @$t, $i, 1;
         }
      }
      &$wrap(\$p, $t, \$i, $width);
   }
   for (my $i= 0; $i < @$t; ) {
      if ($t->[$i] =~ /^\s/) {
         push @t, splice @$t, $i, 1;
         next;
      }
      if (@t) {
         &normalize_indentation(\@t, %opt, -first => $opt{-indent});
         splice @$t, $i, 0, @t;
         $i+= @t;
         @t= ();
      }
      ++$i;
   }
   if (@t) {
      &normalize_indentation(\@t, %opt, -first => $opt{-indent});
      push @$t, @t;
   }
   substr($_, 0, 0)= $opt{-first} foreach grep $_ ne '', @$t;
   $$tref= join '', map "$_\n", @$t if ref($tref) ne 'ARRAY';
}


sub wrap0(@) {
   my $text= join ' ', @_;
   normalize_indentation \$text, -indent => '    ', -wrap => 79;
   return \$text;
}


sub pwrap(@) {
   print ${wrap0 @_};
}


$ENV{LC_ALL}= "C";
my $home= $ENV{HOME};
unless ($home && -d $home) {
   die 'Please set $HOME to your home directory';
}
$home =~ s!/*$!/!;
substr($script, 0, 0)= $home;
if (-e $script) {
   die "Please remove the existing '$script'.\nIt is in the way";
}
pwrap "$0 -", << '.';
Recompile Entire System Helper

Script version as of $Date: 2006-09-26T04:22:55.640944Z $

Written in 2006 by Guenther Brunthaler

This script will generate another script to be run by you. That other script
will then recompile each and every package in the whole system in the correct
order.

This will typically be required on a major GCC upgrade.

When the generated script will be run, it will log all of its screen output
to a log file.

Furthermore, the generated script will automatically skip failing packages and
automatically attempt to recompile them again after all the other packages
have been recompiled.

IMPORTANT: Do not execute this script without also following the steps of the
accompanying usage guide.

The guide can be found at
http://forums.gentoo.org/viewtopic-t-494331-highlight-.html

Press [Ctrl]+[C] now in order to abort processing if you are not following the
guide step by step. Come back and re-run this script after you have managed to
get the guide.

Press [Enter] now to continue if you dare.

.
<STDIN>;
my $tmp= tmpnam or die "No temporary file names left";
print "Collecting list of packages and evaluating installation order...\n";
my @head= qw(
   sys-kernel/linux-headers
   sys-devel/gcc
   sys-libs/glibc
   sys-devel/binutils
);
my $r= join '|', map quotemeta, @head;
$r= qr/ ^ (?: $r ) - \d /x;
open OUT, (
   '| sort -k1,1 | sort -suk3,3 | sort -nk2,2 | sort -sk1,1 '
   . '| cut -d" " -f3 >> "' . $tmp . '"'
) or die "Cannot open output pipe: $!";
my $n= 0;
foreach my $f (qw/system world/) {
   open IN, "emerge -pe $f |" or die "Cannot open input pipe for '$f': $!";
   while (defined($_= <IN>)) {
      if (/]\s+(.*?)\s/) {
         (my $t, $_)= ($f, $1);
         if (/$r/o) {
            for (my $i= @head; $i--; ) {
               my $L= length $head[$i];
               if (length >= $L && substr($_, 0, $L) eq $head[$i]) {
                  print OUT "begin $i";
                  goto field3;
               }
            }
         }
         print OUT "$t ", ++$n;
         field3:
         print OUT " =$_\n";
      }
   }
   close IN or die $!;
}
close OUT or die $!;
open IN, '<', $tmp or die "Cannot open file '$tmp': $!";
open OUT, '>', "$script" || die "Could not create '$script': $!";
print OUT $script_header;
$n= 1;
while (defined($_= <IN>)) {
   next if m!^=sys-devel/gcc!; # It's already up to date!
   print OUT "item $n $_"; ++$n;
}
print OUT $script_tail;
close OUT or die "Could not finish writing '$script': $!";
close IN or die $!;
unlink($tmp) == 1 or warn "Could not remove temorary file '$tmp': $!";
unless (chmod(0755, $script) == 1) {
   die "Could not set permissions for '$script': $!";
}
pwrap << ".";
Done.

Script "$script" has been generated.

Run this script in order to recompile each and every package in the
system!

By the way, the generated script will do this in a recoverable way:
It can be aborted at any time by you, and will continue where it left off
when you re-run it. (The package where the script was interrupted will
have to be compiled again from its beginning, though.)
.
