#!/usr/bin/perl -w
# Invert a mythtv cutlist

my $last_frame = shift;
my $cutlist_file = shift;
my @cuts;
my $command = "";

@cuts = split("\n",`cat $cutlist_file`);
my @skiplist;
foreach my $cut (@cuts) {
    push @skiplist, (split("-", $cut))[0];
    push @skiplist, (split("-", $cut))[1];
}

my $cutnum = 0;
if ($skiplist[0] ne 0) {
    $command .= "-";
    $cutnum = 1;
}

foreach my $cut (@skiplist) {
    if ($cut <= $last_frame) {
        if ($cutnum eq 0) {
            if( $cut ne 0 ) {
                $cutnum = 1;
                $cut++;
                $command .= "$cut-";
            }
        } else {
            $cutnum = 0;
            $cut--;
            $command .= "$cut ";
        }
    }
}

print "$command"
