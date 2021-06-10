#!/usr/bin/perl

use strict;
#use Encode;
use utf8; binmode STDOUT, ":utf8";

use CGI qw(:standard escape);
use CGI::Carp qw(fatalsToBrowser);

use HTTP::Request;
use LWP::UserAgent;

use DBI();
use lib("/hp/af/ag/ri/files/perllib");
use revodb;

use JSON;
my $json_parser = JSON->new->allow_nonref;

my $uwn_url = 'http://www.lexvo.org';

# multajn 3-signajn lingvokodojn ni povos simple mallongigi al 2-signaj
# my $lng_3_2 = abk, aar, afr, aka, sqi, amh, ara, hye, asm, ava, aym, aze, bak, eus, bel, bis, bre,
#     mya, cat, cha, nya, zho, cos, cre, hrv, dan, nld, dzo, eng, fin, fra, glg, kat, deu, ell,
#     guj, hau, heb, hin, hun, isl, ita, kik, kor, kur, lat, lub, mkd, msa, nau, nde, nep, iii,
#     oci, oji, ori, pan, fas, que, ron, rus, san, smo, srp, sna, sin, slv, som, sun, swa, ssw,
#     tam, tel, tgk, tha, tir, bod, tso, twi, ukr, urd, uzb, ven, vie, vol, cym, wol, xho, yld,
#     yid, yor, zha, zul;
# my $lng_3_3 = ;
my $lng32 = {arg => 'an', ave => 'ae', bam => 'bm', ben => 'bn', bih => 'bh', bos => 'bs',
bul => 'bg', che => 'ce', chv => 'cv', cor => 'kw', ces => 'cs', alb => 'sq', arm => 'hy',
baq => 'eu', bur => 'my', chi => 'zh', cze => 'cs', div => 'dv', dut => 'nl', epo => 'eo',
est => 'et', ewe => 'ee', fao => 'fo', fij => 'fj', ful => 'ff', geo => 'ka', ger => 'de', 
gre => 'el', grn => 'gn', hat => 'ht', her => 'hz', hmo => 'ho', ina => 'ia', ind => 'id',
ile => 'ie', gle => 'ga', ibo => 'ig', ipk => 'ik', ido => 'io', ice => 'is', iku => 'iu',
jpn => 'ja', jav => 'jv', kal => 'kl', kan => 'kn', kau => 'kr', kas => 'ks', kaz => 'kk',
khm => 'km', kin => 'rw', kir => 'ky', kom => 'kv', kon => 'kg', kua => 'kj', ltz => 'lb',
lug => 'lg', lin => 'ln', lao => 'lo', lit => 'lt', lav => 'lv', glv => 'gv', mlg => 'mg',
mal => 'ml', mlt => 'mt', mri => 'mi', mar => 'mr', mah => 'mh', mon => 'mn', nav => 'nv',
ndo => 'ng', nob => 'nb', nno => 'nm', nor => 'no', nbl => 'nr', chu => 'cu', orm => 'om',
per => 'fa', pli => 'pi', pol => 'pl', pus => 'ps', por => 'pt', roh => 'rm', rum => 'ro',
srd => 'sc', snd => 'sd', sme => 'se', sag => 'sg', gla => 'gd', slk => 'sk', sot => 'st',
spa => 'es', swe => 'sv', tib => 'bo', tuk => 'tk', tgl => 'tl', tur => 'tr', tat => 'tt',
tah => 'ty', uig => 'ug', wln => 'wa', fry => 'fy'};

# wiktionary-serĉo eblas per:
# http://www.lexvo.org/data/term/epo/kuri

# ekz-e 
# /uwn/entity/epo/kuri
# /uwn/entity/s/v1926311

print header(-type=>'application/json',-charset=>'utf-8');
my $kapj;

#my $json_parser = JSON->new->allow_nonref;
my $art = param('art');

if ($art) {

    exit 1 unless ($art =~ /^[a-z0-9]{1,50}$/);

    # ni elprenu la kapvortojn en la datumbazo
    my $dbh = revodb::connect();
    # necesas por certigi aprioran signokodadon!
    $dbh->{'mysql_enable_utf8'}=1;
    $dbh->do("set names utf8");

    my $sth = $dbh->prepare("select kap,mrk from r3kap where mrk like ?");
    eval { $sth->execute($art.'.%'); };

    if ($@) {
        print $json_parser->encode({
            eraro => $sth->err,
            msg => substr($@,0,81)
        });
        # fermu la datumbazon
        $dbh->disconnect() or die "Fermo de la datumbazo ne funkciis";
        exit;
    } else {
        $kapj = $sth->fetchall_arrayref();
    }    
    # fermu la datumbazon
    $dbh->disconnect() or die "Fermo de la datumbazo ne funkciis";

} else {
    my $s = param('sercho');
    # ni kontrolu la serĉatan vorton, sed ja permesu kelkajn apartajn signojn por
    # permesi ion kiel (n,p)-matrico ks:
    exit 1 unless ($s =~ /^[\pL\-\+]{0,50}$/);
    $kapj = [[$s,'']];
}

my $results = {};

# nun ni serĉu je interlingvaj ligoj de Vikipedio (langlinks)
my $first = $kapj->[0]; # provizore ni serĉos nur pri la unua kapvorto...
my $sercho = escape($first->[0]);
my $res = get_page("/uwn/entity/epo/$sercho");

# en lexvo/uwn ŝajne ne eblas RDF, sed nur HTML, do ni devos serĉi rezultojn en la HTML
#print "$result\n\n";
$res =~ s/<td[^>]*>means<\/td>\s*<td>(.*?)<\/td>/meaning($1)/sieg;

print $json_parser->encode($results);

#########################################################

my $desc;
my $lex;

sub meaning {
    my $a = shift;

    #print "A: $a\n";

    $desc = [];
    $lex = {};

    if ($a =~ /<a\s+href="([^"]+)">(.*?)<\/a>/) {
        my $url = $1;
        my $dsc = $2; 
        my $data = get_page($1);
        $dsc =~ s/<[^>]+>/ /sg;

        #print "RES: $dsc $url\n";
        #print "DATA: $data\n\n\n";

        $data =~ s/<tbody(?:[^>]+"display:(none)")?>(.*?)<\/tbody>/tbody($1,$2)/sieg;

        my $r = (split /;/, $url)[0]; 
        $results->{$r} = {
            dsc => $dsc,
            dif => $desc,
            trd => $lex
        }
    }

    sub tbody {
        my ($duba,$c) = @_;
        #print "TBODY: $c\n\n";

        $c =~ s/<td[^>]*>has gloss<\/td>\s*<td>epo:\s*(.*?)<\/td>/epo_desc($1,$duba)/sieg;
        $c =~ s/<td[^>]*>lexicalization<\/td>\s*<td>(.*?)<\/td>/lex($1,$duba)/sieg;
    }

    # NOTO: ne ĉiam enestas epo-priskribo apud la angla, ĉu rigardi ankaŭ pri alilingvaj?
    sub epo_desc {
        my ($s,$duba) = @_;
        if ($s =~ /<span[^>]*>(.*?)<\/span/) {
            #print "DIF: $1\n";
            my $d = $1; $d =~ s/<[^>]+>/ /sg;
            $d = '?;'.$d if ($duba);
            push @$desc, $d;
        }
    }

    sub lex {
        my ($a,$duba) = @_;

        if ($a =~ /<a\s+href="([^"]+)">([a-z]{3}):\s+<span[^>]*>([^<]+)<\//) {
            #print "$2: $3\n";
            my $l = $lng32->{$2} || substr($2,0,2);
            my $t = ($duba? '?;'.$3 : $3);
            unless (defined $lex->{$l}) {
                $lex->{$l} = [$t];
            } else {
                push @{$lex->{$l}}, $t
            }
        }
    }
}


sub get_page {
    my $page = shift;
    my $request = HTTP::Request->new(GET=>$uwn_url.$page);

    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);

    if ($response->is_success) {
        return $response->decoded_content;
    } else {
        die $response->status_line;
    }
}
