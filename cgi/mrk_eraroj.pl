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
use lib("/hp/af/ag/ri/files/perllib");
use revodb;

use JSON;
my $json_parser = JSON->new->allow_nonref;

my $limit = 50;

print header(-type=>'application/json',-charset=>'utf-8');

# Malfermu la datumbazon
my $dbh = revodb::connect();
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set names utf8");

my ($drv) = $dbh->selectall_arrayref(
    "SELECT mrk,kap FROM r3kap WHERE mrk LIKE '%.%.%' LIMIT $limit");
my ($snc) = $dbh->selectall_arrayref(
    "SELECT  r3mrk.mrk,ele,drv FROM r3mrk "
    ."LEFT JOIN r3kap ON r3kap.mrk = r3mrk.drv "
    ."WHERE r3kap.kap IS NULL LIMIT $limit");

# homonimoj:
my $hom = $dbh->selectall_arrayref(
    "SELECT DISTINCT a.kap, a.mrk, b.mrk FROM r3kap a, r3kap b "
    ."WHERE a.kap=b.kap AND SUBSTRING_INDEX(a.mrk,'.',1) <> SUBSTRING_INDEX(b.mrk,'.',1) "
    ."AND NOT EXISTS (SELECT * FROM r3ref r WHERE r.tip='hom' "
    ."AND SUBSTRING_INDEX(r.mrk,'.',2) = SUBSTRING_INDEX(a.mrk,'.',2) "
    ."AND SUBSTRING_INDEX(r.cel,'.',2) = SUBSTRING_INDEX(b.mrk,'.',2) "
    .") ORDER BY a.kap LIMIT $limit");
# anst. SUBSTRING_INDEX ...2 ankaŭ eblas testi kompletan entenon: 
# and greatest(instr(r.mrk,a.mrk),instr(a.mrk,r.mrk))=1 
# and greatest(instr(r.cel,b.mrk),instr(b.mrk,r.cel))=1) 

print $json_parser->encode({drv=>$drv, snc=>$snc, hom=>$hom});
$dbh->disconnect() or die "DB-malkonekto ne funkcias";

