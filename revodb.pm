#!/usr/bin/perl

#
# revodb.pm
# 
# 2006-09-__ Wieland Pusch
# 2008-10-__ Wieland Pusch
#

use strict;

package revodb;

use DBI();

######################################################################
sub connect {
  # Connect to the database.
  my $dbh = DBI->connect("DBI:mysql:database=usr_web277_1;host=abelo;port=3306",
                         "root", "sekreto",
                         {'RaiseError' => 1}) or die "DB ne funkcias";
  $dbh->do("set names utf8");
  return $dbh;
}
######################################################################

sub pop3login {
  return ("XXX", "XXX");
}
######################################################################

sub mysqldump {
  return "mysqldump --user=root --password=sekreto --databases usr_web277_1";
}
######################################################################

sub mail_from {
  return 'XXX';
}

sub mail_to {
  return 'XXX';
}

1;
;
