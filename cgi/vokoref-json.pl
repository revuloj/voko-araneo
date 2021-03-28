#!/usr/bin/perl 
#
# (c) 2021 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0

use strict;

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
#use URI::Escape;
use JSON;


# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
#use Unicode::String qw(utf8);
use Encode;
use utf8; binmode STDOUT, ":utf8";
use revodb;

my $debug = 0;
my $LIMIT = 250;

my $json_parser = JSON->new->allow_nonref;
my $art = param('art'); 

# serĉo en la datumbazo
my $dbh = revodb::connect();
# necesas!
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

print header(-type=>'application/json',-charset=>'utf-8');
if ($art =~ /^[a-z0-9]+$/) {
    refs();
}

# fino
$dbh->disconnect() or die "Malkonekto de la datumbazo ne funkciis";
exit;

###########

sub refs {
    my $res = $dbh->selectall_arrayref("SELECT vik_celref, vik_artikolo FROM r2_vikicelo "
        . "WHERE vik_celref = '$art' OR vik_celref LIKE '$art.%'");
        #'vik_celref');
    my $refs = {viki=>$res};
    print $json_parser->encode($refs);
}


