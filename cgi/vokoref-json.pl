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
    my $viki = viki_refs();
    my $tez = tez_refs();
    print $json_parser->encode({viki=>$viki, tez=>$tez});
}

# fino
$dbh->disconnect() or die "Malkonekto de la datumbazo ne funkciis";
exit;

###########

sub viki_refs {
    my $rows = $dbh->selectall_arrayref("SELECT vik_celref AS m, vik_artikolo AS v FROM r2_vikicelo "
        . "WHERE vik_celref = '$art' OR vik_celref LIKE '$art.%' LIMIT $LIMIT", { Slice=>{} }); #,{0=>'m',1=>'v'});
        #'vik_celref');
    return $rows;
}

sub tez_refs {
    my $rows = $dbh->selectall_arrayref("SELECT DISTINCT mrk,tip,cel,lst,kap,num "
        . "FROM v3tezauro WHERE mrk LIKE '$art.%' "
        . "LIMIT $LIMIT", { Slice=>{} }); 
    

    my @refs;
    # strukturu la rezultojn
    for my $row (@$rows) {        
        my $cel = { 
            'm' => $row->{cel},
            'k' => $row->{kap}
        };
        $cel ->{n} = $row->{num} if ($row->{num});
        $cel ->{l} = $row->{lst} if ($row->{lst});

        my $ref = {
            'tip'=> $row->{tip},
            'mrk'=> $row->{mrk},
            'cel'=> $cel
        };
        #$ref ->{fak} = $row->{fak} if ($row->{fak});
        push @refs, $ref;
    }
    # redonu la rezulton
    return \@refs;
}
