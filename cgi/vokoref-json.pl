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
    my $rows = $dbh->selectall_arrayref("SELECT tez_fontteksto, tez_fontref, tez_fontn, "
        . "tez_celteksto, tez_celref, tez_celn, tez_tipo, tez_fako FROM r2_tezauro "
        . "WHERE tez_kapvorto = '$art' LIMIT $LIMIT", { Slice=>{} });
    my @refs;
    # strukturu la rezultojn
    for my $row (@$rows) {
        # fakte referencoj sen mrk ne havas sencon, sed ili enestas tamen,
        # ekz-e por marki fakon de artikolo - eble iam plibonirug parseart2 kaj la rtabelon r2_tezauro
        # fakindikoj povus havi lokon en alia tabelo!
        if ($row->{tez_fontref} && $row->{tez_celref}) {
            my $fnt = { 
                'm' => $row->{tez_fontref},
                'k' => $row->{tez_fontteksto}
            };
            $fnt->{n} = $row->{tez_fontn} if ($row->{tez_fontn});

            my $cel = { 
                'm' => $row->{tez_celref},
                'k' => $row->{tez_celteksto}
            };
            $cel ->{n} = $row->{tez_celn} if ($row->{tez_celn});

            my $ref = {
                'tip'=> $row->{tez_tipo},
                'fnt'=>$fnt,
                'cel'=>$cel
            };
            $ref ->{fak} = $row->{tez_fako} if ($row->{tez_fako});
            push @refs, $ref;
        }
    }
    # redonu la rezulton
    return \@refs;
}

	