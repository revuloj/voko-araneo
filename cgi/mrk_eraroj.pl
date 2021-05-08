#!/usr/bin/perl

# mrk_eraroj.pl
# 
# (c) 2021 Wolfram Diestel
# laŭ permesilo GPL 2.0

# trovas malĝustajn markojn
# drv@mrk tri- aŭ plipartaj
# snc@mrk, subsnc@mrk kiuj ne havas drv@mrk kiel prefikson

use strict;

use CGI qw(header);
use CGI::Carp qw(fatalsToBrowser);
use DBI();

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri//files/perllib");
use revodb;

use JSON;
my $json_parser = JSON->new->allow_nonref;

my $limit = 50;

print header(-type => 'application/json');

# Malfermu la datumbazon
my $dbh = revodb::connect();


my ($drv) = $dbh->selectall_arrayref("SELECT mrk,kap FROM r3kap WHERE mrk LIKE '%.%.%' LIMIT $limit");
my ($snc) = $dbh->selectall_arrayref("SELECT  r3mrk.mrk,ele,drv FROM r3mrk LEFT JOIN r3kap ON r3kap.mrk = r3mrk.drv "
    ."WHERE r3kap.kap IS NULL LIMIT $limit");

print $json_parser->encode({drv=>$drv, snc=>$snc});
$dbh->disconnect() or die "DB-malkonekto ne funkcias";

