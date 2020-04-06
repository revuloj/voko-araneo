#!/usr/bin/perl

#
# redaktantoj.pl
# 
# 2008 Wieland Pusch
# 2020 Wolfram Diestel
#

use strict;

use CGI qw(:standard);
#use CGI::Carp qw(fatalsToBrowser);
use DBI();

print header(-type=>'application/json', -charset=>'utf-8');

# propraj perl moduloj estas en:
use lib("/var/www/web277/files/perllib");
use revodb;

# Connect to the database.
my $dbh = revodb::connect();

print "[\n"; my $k1='';

my $sth = $dbh->prepare("SELECT red_id, red_nomo FROM redaktanto ORDER BY red_id");
$sth->execute();

while (my ($id, $nomo) = $sth->fetchrow_array()) {
  
  print $k1."{\"red_id\":\"".$id."\",\"red_nomo\":\"".$nomo."\",\"retadr\":[";

  my $sth2 = $dbh->prepare("SELECT ema_email FROM email WHERE ema_red_id = ? ORDER BY ema_sort");
  $sth2->execute($id);

  my $k2='';
  while (my ($email) = $sth2->fetchrow_array()) {
    print "$k2\"$email\""; $k2=',';
  }
  print "]}\n"; $k1=',';  
}

print "]\n";
$dbh->disconnect() or die "DB-malkonekto ne funkcias";
