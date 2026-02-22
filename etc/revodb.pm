#!/usr/bin/perl

#
# revodb.pm
# 
# 2006-09-__ Wieland Pusch
# 2008-10-__ Wieland Pusch
# 2019-26 - Wolfram Diestel

# revodb.pm - por konekti al la mysql-servilo ene de Docker-medio
# por la publika servilo, adaptu la samnoman dosieron en cgi/perllib/

use strict;
package revodb;
use DBI();

open(my $fh,'<','/run/secrets/voko-abelo.mysql_password')
  or die "Mi ne trovis la pasvort-sekreton: $!";
 
my $mysql_password = <$fh>;
chomp $mysql_password;
close $fh;

######################################################################
sub connect {
  # konekto al la datumbazo, agordu host=... en la publika servilo, 
  # tls-parametroj vd. https://github.com/perl5-dbi/DBD-mysql/issues/110
  #### DBI->trace("2|CON");
  # my $dbh = DBI->connect("DBI:mysql:database=db314802x3159000;host=abelo;port=3306;mysql_ssl_optional=1;mysql_ssl_ca=/usr/local/share/ca-certificates/mysql-server-2.crt;mysql_ssl_verify_server_cert=0",

my $dbh = DBI->connect("DBI:mysql:database=db314802x3159000;host=abelo;port=3306",
                         "s314802_3159000", $mysql_password,
                         {
                          'RaiseError' => 1
                         }) or die "DB ne funkcias";
  $dbh->do("set names utf8");
  return $dbh;
}
######################################################################

sub pop3login {
  return ("XXX", "XXX");
}
######################################################################

sub mysqldump {
  open(my $fh,'<','/run/secrets/voko-abelo.mysql_root_password')
    or die "Mi ne trovis la pasvort-sekreton: $!";
  my $mysql_root_password = <$fh>;
  chomp $mysql_root_password;
  close $fh;

  return "mysqldump --user=root --password=$mysql_root_password --databases db314802x3159000";
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
