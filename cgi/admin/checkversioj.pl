#!/usr/bin/perl

#
# checkversioj.pl
# 
# 2008 Wieland Pusch
# 2021 Wolfram Diestel
#
# komparas XML-/JSON-dosierojn kaj datumbazon por detekti korektendajn diferencojn
# 

use strict;

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
# use Array::Utils qw(:all);

use JSON;
my $json_parser = JSON->new->allow_nonref;

print header(
  -type => 'application/json',
  -charset => 'utf-8');

my $homedir = "/hp/af/ag/ri";
my $xmldir = "$homedir/www/revo/xml";
my $artdir = "$homedir/www/revo/art";
my $tezdir = "$homedir/www/revo/tez";

my ($xml,$art,$tez);
for (glob "$xmldir/*.xml") { /([^\/]+)\.xml$/; $xml->{$1} = 1 };
for (glob "$artdir/*.html") { /([^\/]+)\.html$/; $art->{$1} = 1 };
for (glob "$tezdir/*.json") { /([^\/]+)\.json$/; $tez->{$1} = 1 };
#my @art = map { /([^\/]+)\.html$/; $1 } glob "$artdir/*.html";
#my @tez = map { /([^\/]+)\.json$/; $1 } glob "$tezdir/*.json";
#my @x_a = grep { not ($_ ~~ @art) } @xml;
#my @a_x = grep { not ($_ ~~ @xml) } @art;

my @x_a = grep { not exists ($art->{$_}) } keys %$xml;
my @a_x = grep { not exists ($xml->{$_}) } keys %$art;
my @x_t = grep { not exists ($tez->{$_}) } keys %$xml;
my @t_x = grep { not exists ($xml->{$_}) } keys %$tez;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use revodb;

# Malfermu la datumbazon 
my $dbh = revodb::connect();
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

my $db = $dbh->selectall_hashref("SELECT DISTINCT SUBSTRING_INDEX(mrk,'.',1) AS mrk FROM r3kap",'mrk');

#print join(';',keys %$db);
my @t_d = grep { not exists ($db->{$_}) } keys %$tez;
my @d_t = grep { not exists ($tez->{$_}) } keys %$db;

$dbh->disconnect() or die "Ne eblis fermi la DB-on.\n";

print $json_parser->encode({
  "xml-art" => \@x_a,
  "art-xml" => \@a_x,
  "xml-tez" => \@x_t,
  "tez-xml" => \@t_x,
  "tez-db"  => \@t_d,
  "db-tez"  => \@d_t,
  tempo => (time - $^T)
});


