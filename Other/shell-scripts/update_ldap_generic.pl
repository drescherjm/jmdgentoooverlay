#!/usr/bin/perl -w
# by Aleksander Adamowski
# Wed Apr 27 19:55:55 CEST 2005: initial version
# Tue May 24 18:49:00 CEST 2005: multi ADD
# Wed, 23 Apr 2008 12:39:02 +0200: translated everything into English
# 
# update_ldap.pl SET 'attribute=value' WHERE '(LDAP_FILTER)'
# update_ldap.pl ADD 'attribute=value'[,attribute2=value2',...] WHERE '(LDAP_FILTER)'
# update_ldap.pl REPLACE 'attribute=value' WITH 'attribute=new_value' WHERE '(LDAP_FILTER)'

use Net::LDAP;
use Config::Simple;
use File::Glob ':glob';
use strict;

our $LDAP_CONF = '/etc/openldap/ldap.conf';
our $PRIV_CONF = '~/.update_ldap.rc';


if (scalar(@ARGV) < 4 || ($ARGV[2] ne 'WHERE' && $ARGV[2] ne 'WITH')) {
  print <<EOD
Usage:
 $0 SET 'attribute=value' WHERE '(LDAP_FILTER)'
 $0 ADD 'attribute=value[,attribute2=value2,...]' WHERE '(LDAP_FILTER)'
 $0 REPLACE 'attribute=value' WITH 'attribute=new_value' WHERE '(LDAP_FILTER)'

Examples:
Setting a common password for all users:
 $0 SET 'userPassword=migration.3781' WHERE '(objectclass=person)'

Change the 'tr' value in the organizational unit attribute from 'tr' to 
'training' for all persons who have 'tr' among the values of the ou attribute 
(leaves other values of the same attribute intact - removes only the 'tr' 
value):
 $0 REPLACE 'ou=tr' WITH 'ou=training' WHERE '(ou=tr)'

Adding an additional 'marketing_peon' organizational unit for all employees who 
are in 'marketing' ou but are not in the 'management' ou (employees who have 
both ou=marketing and ou=management won't be affected):
 $0 ADD 'ou=marketing peon' WHERE '(&(ou=marketing)(!(ou=management)))'

Configuration:
 The URI and BASE options must be configured in $LDAP_CONF.
 The BIND_DN and PASSWORD options must be set in $PRIV_CONF, e.g.:

BIND_DN=cn=Manager
PASSWORD=IamDirectoryManager17833#@913&^#

 If PASSWORD isn't specified, it will be asked for interactively.

EOD
} else {
  my $cfg = new Config::Simple($LDAP_CONF);
  my $uri = $cfg->param('URI');
	if (!defined($uri)) {
    die "URI undefined!\n";
	}
  my $base_dn = $cfg->param('BASE');
	if (!defined($base_dn)) {
    die "BASE undefined!\n";
	}
  my $cfg_private = new Config::Simple(glob($PRIV_CONF));
  my $bind_dn = $cfg_private->param('BIND_DN');
	if (!defined($bind_dn)) {
    die "BIND_DN undefined!\n";
	}
  my $pw = $cfg_private->param('PASSWORD');
	if (!defined($pw)) {
		system "stty -echo";
		print "Supply bind password for user $bind_dn:";
		chomp($pw = <STDIN>);
		print "\n";
		system "stty echo";
	}
  my $ldap_source = Net::LDAP->new($uri) or die "$@";
  my $mesg = $ldap_source->bind( $bind_dn, password => $pw);
  if ($mesg->code != 0) {
    print STDERR "LDAP Error! ".$mesg->error."\n";
    die "Error:>\n".$mesg->error."\n";
  } else {
    print "Bound to LDAP server $uri as $bind_dn. Base DN is $base_dn.\n\nSearching for objects...\n";
  }
  my $oper = $ARGV[0];
  my $filter = undef;
  if ($oper eq 'REPLACE') {
    $filter = $ARGV[5];
  } else {
    $filter = $ARGV[3];
  }
  if (!defined($filter)) { die "incorrect filter!\n" };
  my $result = $ldap_source->search(filter => $filter, base => $base_dn);
  my @entries = $result->entries;
  my $count = scalar(@entries);
  if ($count <= 0) {
    die "Found $count objects.\n";
  }
  print "Count of objects to be modified: $count\n\n";
  print "Type 'ok' to continue. Type any other text or press CTRL-C to abort.";
  chomp(my $chosen = <STDIN>);
  print "\n";
  if ($chosen ne 'ok') {
    die "Didn't receive 'ok', operation cancelled.\n";
  }
  print "\n";
  if ($oper eq 'SET') {
    # Setting attribute to a new single value:
    if ($ARGV[1] =~ /^([a-zA-Z0-9]+)\=(.*)$/) {
      my $attr = $1;
      my $value = $2;
      print "Setting <$attr> to <$value> in $count objects:\n";
      my $entry;
      foreach $entry (@entries) {
        print $entry->dn;
        $entry->replace($attr => $value);
        $mesg = $entry->update($ldap_source);
        if ($mesg->code != 0) {
          print "LDAP Error! ".$mesg->error;
        }
        print "\n";
      }
    } else {
      die "Incorrect argument syntax:\n".$ARGV[1]."\n";
    }

  } elsif ($oper eq 'ADD') {
    # Adding new values to attributes:
    my @adders;
    if ($ARGV[1] =~ /,/) {
      # Multiple added attr-value pairs separated by commas:
      @adders = split /,/, $ARGV[1];
    } else {
      @adders = ($ARGV[1]);
    }
    my $entry;
    print "Adding values to ".scalar(@entries)." objects\n";
    foreach $entry (@entries) {
      print $entry->dn.":\n";
      foreach my $adder (@adders) {
        if ($adder =~ /^([a-zA-Z0-9]+)\=([^,]*)$/) {
          my $attr = $1;
          my $value = $2;
          print "  adding value to <$attr>, value <$value>\n";
          $entry->add($attr => $value);
        } else {
          die "Incorrect argument syntax:\n".$adder."\n";
        }
      }
      $mesg = $entry->update($ldap_source);
      if ($mesg->code != 0) {
        print "  LDAP Error! ".$mesg->error."\n";
      } else {
        print "  OK\n";
      }
    }

  } elsif ($oper eq 'REPLACE') {
    # Replacing incidences of a given attribute value with an other value in 
    # a possibly multi-valued attribute:
    if ($ARGV[1] =~ /^([a-zA-Z0-9]+)\=(.*)$/) {
      my $attr = $1;
      my $oldvalue = $2;
      if ($ARGV[3] =~ /^([a-zA-Z0-9]+)\=(.*)$/) {
        my $newattr = $1;
        my $newvalue = $2;
        if ($attr ne $newattr) {
          die "$attr and $newattr don't match!\n";
        }
        print "Changing values in <$attr>, old value: <$oldvalue> (if exists), ".
          "new value: <$newvalue>.\nChanging in $count objects:\n";
        my $entry;
        my $replacement_count = 0;
        foreach $entry (@entries) {
          #$entry->add($attr => $value);
          my @values = $entry->get_value($attr);
          my @values_out = ();
          my $found = 0;
          foreach my $value (@values) {
            if ($value eq $oldvalue) {
              #print " found $oldvalue, changing to $newvalue; ";
              push @values_out, $newvalue;
              $found = 1;
            } else {
              push @values_out, $value;
            }
          }
          if ($found) {
            print $entry->dn;
            $entry->replace($attr => \@values_out);
            print ': updated to: '.join(', ', $entry->get_value($attr));
            $replacement_count++;

            $mesg = $entry->update($ldap_source);
            if ($mesg->code != 0) {
              print "LDAP Error! ".$mesg->error;
            }
            print "\n";
          }
        }
        print "Summary: updated $replacement_count values.\n";
      } else {
        die "Incorrect target syntax:\n".$ARGV[3]."\n";
      }
    } else {
      die "Incorrect source syntax:\n".$ARGV[1]."\n";
    }
  } else {
    print "Unsupported operation: $oper\n";
  }
  print "\n";
}


