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
    # ni kolektas referencojn en ambaŭ referencoj, por la kontraŭa direkto 
    # ni interŝanĝas fonton kaj celon kaj la referenctipon:
    # KOREKTU: por la inversa direkto ni devos interŝanĝi 
    # dif->sin, sub->super, super->sub, prt->malprt, malprt->prt, (lst->ekz, ekz->lst)
    my $rows = $dbh->selectall_arrayref(
          "SELECT tez_fontteksto AS fk, tez_fontref AS fm, tez_fontn AS fn, "
        .   "tez_celteksto AS ck, tez_celref AS cm, tez_celn AS cn, "
        .   "tez_tipo AS tip, tez_fako AS fak FROM r2_tezauro "
        . "WHERE tez_kapvorto = '$art' AND tez_celteksto != '???' "
        .   "AND tez_fontref IS NOT NULL AND tez_celref IS NOT NULL "
        . "UNION SELECT tez_celteksto AS fk, tez_celref AS fn, tez_celn AS fn, "
        .   "tez_fontteksto AS ck, tez_fontref AS cm, tez_fontn AS cn, "
        .   "CASE tez_tipo WHEN 'dif' THEN 'sin' WHEN 'sub' THEN 'super' WHEN 'super' THEN 'sub' "
        .     "WHEN 'prt' THEN 'malprt' WHEN 'malprt' THEN 'prt' WHEN 'ekz' THEN 'super' "
        .     "ELSE tez_tipo END AS tip, tez_fako AS fak FROM r2_tezauro "
        . "WHERE tez_celref LIKE '$art.%' AND tez_celteksto != '???' "
        .   "AND tez_fontref IS NOT NULL AND tez_celref IS NOT NULL "
        . "LIMIT $LIMIT", { Slice=>{} });
        # fakte referencoj sen mrk (tez_fontref, tez_celref) ne havas sencon, sed ili enestas tamen,
        # ekz-e por marki fakon de artikolo - eble iam plibonirug parseart2 kaj la rtabelon r2_tezauro
        # fakindikoj povus havi lokon en alia tabelo!
    my @refs;
    # strukturu la rezultojn
    for my $row (@$rows) {        
        my $fnt = { 
            'm' => $row->{fm},
            'k' => $row->{fk}
        };
        $fnt->{n} = $row->{fn} if ($row->{fn});

        my $cel = { 
            'm' => $row->{cm},
            'k' => $row->{ck}
        };
        $cel ->{n} = $row->{cn} if ($row->{cn});

        my $ref = {
            'tip'=> ($row->{tip} eq 'sup'? 'super' : $row->{tip}),
            'fnt'=> $fnt,
            'cel'=> $cel
        };
        $ref ->{fak} = $row->{fak} if ($row->{fak});
        push @refs, $ref;
    }
    # redonu la rezulton
    return \@refs;
}

	