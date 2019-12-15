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
  #  my $dbh = DBI->connect("DBI:mysql:database=usr_web277_1;host=127.0.0.1",
  my $dbh = DBI->connect("DBI:mysql:database=usr_web277_1;host=0.0.0.0;port=3366",
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
#  return "mysqldump --user=XXX --password=XXX --databases XXX";
  return "mysqldump --user=web277 --password=<pwd> --ignore-table=usr_web277_1.r2_vikititolo --ignore-table=usr_web277_1.email --ignore-table=usr_web277_1.redaktanto --databases usr_web277_1";
}
######################################################################

sub mail_from {
  return 'XXX';
}

sub mail_to {
  return 'revuloj@groups.io'; # povas esti pluraj dividitaj per komo
}

1;
;
