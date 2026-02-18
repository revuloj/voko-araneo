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
  # konekto al la datumbazo, agordu host=... kaj forigu mysql_ssl_verify_server_cert=0
  # en la publika servilo, tls-parametroj vd. https://github.com/perl5-dbi/DBD-mysql/issues/110
  DBI->trace("2|CON");

# DBD::mysql versio 4.054 ial ne fidas al la memfaritaj atestiloj de la mysql-servo - eble cimo
# ĉar antaŭe funkciis!?
#$ apk add openssl
#$ openssl s_client -starttls mysql -connect abelo:3306 -showcerts
#    Server certificate
#    subject=CN=MySQL_Server_5.7.43_Auto_Generated_Server_Certificate
#    issuer=CN=MySQL_Server_5.7.43_Auto_Generated_CA_Certificate

# provu:
# apk add openssl
# openssl s_client -starttls mysql -connect abelo:3306 -showcerts > mysql.cert.pem
# quit
# 1. Create the folder if it doesn't exist
# 2. Copy your cert there (must have .crt extension)
#cp mysql.cert.pem /usr/local/share/ca-certificates/mysql-server.crt
# 3. Update the system trust store
#update-ca-certificates
#10.0.0.5        abelo   MySQL_Server_5.7.43_Auto_Generated_Server_Certificate MySQL_Server_5.7.43_Auto_Generated_CA_Certificate


# https://github.com/perl5-dbi/DBD-mysql/issues/300
# https://github.com/MariaDB/server/blob/10.4/sql-common/client.c#L1577
# https://serverfault.com/questions/399487/cant-connect-to-mysql-using-self-signed-ssl-certificate
# https://github.com/docker-library/mysql/blob/master/docker-entrypoint.sh
# https://dev.mysql.com/doc/refman/8.0/en/creating-ssl-rsa-files-using-mysql.html#creating-ssl-rsa-files-using-mysql-automatic

# https://github.com/perl5-dbi/DBD-mysql/blob/b06d146dc5f9a0913c757e0ba8548bd0f561fbfc/dbdimp.c#L1437

  #my $dbh = DBI->connect("DBI:mysql:database=db314802x3159000;host=abelo;port=3306;mysql_ssl_optional=1;mysql_ssl_verify_server_cert=0;mysql_ssl_ca=/dev/null",
  #my $dbh = DBI->connect("DBI:mysql:database=db314802x3159000;host=abelo;port=3306;mysql_ssl=1;mysql_ssl_ca=/usr/local/share/ca-certificates/mysql-server-2.crt;mysql_ssl_verify_server_cert=0",
my $dbh = DBI->connect("DBI:mysql:database=db314802x3159000;host=abelo;port=3306;mysql_ssl_optional=1;mysql_ssl_ca_file=/usr/local/share/ca-certificates/mysql-ca.crt;mysql_ssl_verify_server_cert=0",  
# ;mysql_ssl=0
#my $dbh = DBI->connect("DBI:mysql:database=db314802x3159000;host=abelo;port=3306",
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
