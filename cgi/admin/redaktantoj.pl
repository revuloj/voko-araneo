#!/usr/bin/perl

#
# redaktantoj.pl
# 
# 2008-03-28 Wieland Pusch
#

use strict;

use CGI qw(:standard);
#use CGI::Carp qw(fatalsToBrowser);
use DBI();

print header(-type=>'text/plain', -charset=>'utf-8');

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use revodb;

# Connect to the database.
my $dbh = revodb::connect();

my $sth = $dbh->prepare("SELECT red_id, red_nomo FROM redaktanto ORDER BY red_id");
$sth->execute();
while (my ($id, $nomo) = $sth->fetchrow_array()){
  print $nomo;

  my $sth2 = $dbh->prepare("SELECT ema_email FROM email WHERE ema_red_id = ? ORDER BY ema_sort");
  $sth2->execute($id);
  while (my ($email) = $sth2->fetchrow_array()) {
    print " <$email>";
  }
  print "\n";
}

$dbh->disconnect() or die "DB disconnect ne funkcias";

