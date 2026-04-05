#!/usr/bin/perl

#
# revodb.pm
# laŭ permesilo GPL 2.0
# 2006-09-__ Wieland Pusch
# 2008-10-__ Wieland Pusch
# 2019 - 2026 ĉ€ Wolfram Diestel

# revodb.pm - por konekti al la mysql-servilo ene de Docker-medio
# por la publika servilo, adaptu la samnoman dosieron en cgi/perllib/

use warnings; use strict;

package revodb;
use DBI();


###################################################


sub get_pwd {
  my $secret_path = shift;
  open(my $fh,'<',$secret_path)
    or die "Mi ne trovis la pasvort-sekreton: $!\n";
  
  my $mysql_password = <$fh>;
  close $fh;

  chomp $mysql_password;
  return $mysql_password;
}

## no critic (Subroutines::ProhibitBuiltinHomonyms)
sub connect {
  # konekto al la datumbazo, agordu host=... en la publika servilo, 
  # tls-parametroj vd. https://github.com/perl5-dbi/DBD-mysql/issues/110
  #### DBI->trace("2|CON");
  # my $dbh = DBI->connect("DBI:mysql:database=db314802x3159000;host=abelo;port=3306;mysql_ssl_optional=1;mysql_ssl_ca=/usr/local/share/ca-certificates/mysql-server-2.crt;mysql_ssl_verify_server_cert=0",

  my $mysql_pwd = get_pwd('/run/secrets/voko-abelo.mysql_password');

  my $dbh = DBI->connect("DBI:mysql:database=db314802x3159000;host=abelo;port=3306",
                         "s314802_3159000", $mysql_pwd,
                         {
                          'RaiseError' => 1
                         }) or die "DB ne funkcias\n";
  $dbh->do("set names utf8");
  return $dbh;
}
##################################################

sub pop3login {
  return ("XXX", "XXX");
}

sub mail_from {
  return 'XXX';
}

sub mail_to {
  return 'XXX';
}

##################################################

sub mysqldump {
  my $mysql_root_pwd = get_pwd('/run/secrets/voko-abelo.mysql_root_password');
  return "mysqldump --user=root --password=$mysql_root_pwd --databases db314802x3159000";
}

1;
;
