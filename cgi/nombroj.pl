#!/usr/bin/perl

# nombroj.pl
# 
# (c) 2021 Wolfram Diestel
# laŭ permesilo GPL 2.0

# redonas la nombron de kapvortoj kaj de tradukoj

use strict;

use CGI qw(header);
use CGI::Carp qw(fatalsToBrowser);
use DBI();

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri//files/perllib");
use revodb;

use JSON;
my $json_parser = JSON->new->allow_nonref;

print header(-type => 'application/json');

# Malfermu la datumbazon
my $dbh = revodb::connect();

#$dbh->{'mysql_enable_utf8'}=1;
#$dbh->do("set names utf8");

my ($kap) = $dbh->selectrow_arrayref("SELECT COUNT(*) FROM r3kap");
my ($trd) = $dbh->selectrow_arrayref("SELECT COUNT(*) FROM r3trd");

print $json_parser->encode({kap=>$kap, trd=>$trd});
$dbh->disconnect() or die "DB-malkonekto ne funkcias";
