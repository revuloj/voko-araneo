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

open(my $fh,'<','/run/secrets/mysql_password')
  or die "Mi ne trovis la pasvort-sekreton: $!";
 
my $mysql_password = <$fh>;
chomp $mysql_password;
close $fh;

######################################################################
sub connect {
  # Connect to the database.
  my $dbh = DBI->connect("DBI:mysql:database=usr_web277_1;host=abelo;port=3306",
                         "web277", $mysql_password,
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
  return "mysqldump --user=root --password=$(cat /run/secrets/mysql_root_password) --databases usr_web277_1";
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