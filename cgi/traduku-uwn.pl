#!/usr/bin/perl

# (c) laŭ permesilo GPL 2.0
# 2021-2026 Wolfram Diestel

use warnings; use strict;

use utf8; use open ':std', ':encoding(UTF-8)';

use CGI qw(-utf8 :standard escape); use CGI::Carp qw(fatalsToBrowser);

use HTTP::Request;
use LWP::UserAgent;

use DBI();
use lib("/hp/af/ag/ri/files/perllib");
use revodb;

use JSON;

# lexwo.org ne plu aktivas ŝajne...
print header(-status => '502 Bad Gateway', -type => 'application/json');
exit;


my $json_parser = JSON->new->allow_nonref;

my $uwn_url = 'http://www.lexvo.org';

# la aliajn (krom preterviditajn) 3-signajn lingvokodojn ni povos simple mallongigi al 2-signaj
my $lng32 = {ace => 'ace', ang => 'ang', arg => 'an', ave => 'ae', bam => 'bm', ben => 'bn', bih => 'bh', 
bos => 'bs', bul => 'bg', che => 'ce', chv => 'cv', cmn => 'cmn', cor => 'kw', ces => 'cs', alb => 'sq', 
arm => 'hy', baq => 'eu', bur => 'my', chi => 'zh', cze => 'cs', div => 'dv', dsb => 'dsb', dut => 'nl', 
egy => 'egy', epo => 'eo', est => 'et', ewe => 'ee', fao => 'fo', fij => 'fj', ful => 'ff', fur => 'fur', 
geo => 'ka', ger => 'de', grc => 'grc', gre => 'el', grn => 'gn', hat => 'ht', hbs => 'sh', her => 'hz', 
hmo => 'ho', hsb => 'hsb', ina => 'ia', ind => 'id', ile => 'ie', gle => 'ga', ibo => 'ig', ipk => 'ik', 
ido => 'io', ice => 'is', iku => 'iu', jpn => 'ja', jav => 'jv', kal => 'kl', kan => 'kn', kau => 'kr', 
kas => 'ks', kaz => 'kk', kha => 'kha', khm => 'km', kin => 'rw', kir => 'ky', kom => 'kv', kon => 'kg', 
kua => 'kj', ltz => 'lb', lug => 'lg', lin => 'ln', lao => 'lo', lit => 'lt', lav => 'lv', lld => 'lld', 
glv => 'gv', mlg => 'mg', mal => 'ml', mlt => 'mt', mri => 'mi', mar => 'mr', mah => 'mh', mon => 'mn', 
nav => 'nv', ndo => 'ng', nob => 'nb', nno => 'nm', nor => 'no', nbl => 'nr', chu => 'cu', orm => 'om', 
per => 'fa', pli => 'pi', pnb => 'pnb', pol => 'pl', pus => 'ps', por => 'pt', roh => 'rm', rum => 'ro', 
scn => 'scn', srd => 'sc', snd => 'sd', sme => 'se', sag => 'sg', gla => 'gd', slk => 'sk', sot => 'st', 
spa => 'es', swe => 'sv', syc => 'syc', tib => 'bo', tuk => 'tk', tgl => 'tl', tur => 'tr', tat => 'tt', 
tah => 'ty', tcy => 'tcy', uig => 'ug', vro => 'vro', war => 'war', wln => 'wa', wym => 'wym', xal => 'xal', 
xcl => 'xcl', yue => 'yue', fry => 'fy', ota => 'ota'};

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

    exit 1 unless ($art =~ m{^
        [a-z0-9]{1,50}
    $}x);

    # ni elprenu la kapvortojn en la datumbazo
    my $dbh = revodb::connect();
    # necesas por certigi aprioran signokodadon!
    $dbh->{'mysql_enable_utf8'}=1;
    $dbh->do("set names utf8");

    my $sth = $dbh->prepare("SELECT kap,mrk FROM r3kap WHERE mrk LIKE ?");
    eval { $sth->execute($art.'.%'); }
        or do {
            warn "Ne eblis elekti datumojn el r3kap\n"
        };

    if ($@) {
        print $json_parser->encode({
            eraro => $sth->err,
            msg => substr($@,0,81)
        });
        # fermu la datumbazon
        $dbh->disconnect() or die "Fermo de la datumbazo ne funkciis.\n";
        exit;
    } else {
        $kapj = $sth->fetchall_arrayref();
    }    
    # fermu la datumbazon
    $dbh->disconnect() or die "Fermo de la datumbazo ne funkciis.\n";

} else {
    my $s = param('sercho');
    # ni kontrolu la serĉatan vorton, sed ja permesu kelkajn apartajn signojn por
    # permesi ion kiel (n,p)-matrico ks:
    exit 1 unless ($s =~ m{^
        [\pL\-\+]{0,50}
    $}x);
    $kapj = [[$s,'']];
}

my $results = {};

# nun ni serĉu je interlingvaj ligoj de Vikipedio (langlinks)
my $first = $kapj->[0]; # provizore ni serĉos nur pri la unua kapvorto...
my $sercho = escape($first->[0]);
my $res = get_page("/uwn/entity/epo/$sercho");

# en lexvo/uwn ŝajne ne eblas RDF, sed nur HTML, do ni devos serĉi rezultojn en la HTML
#print "$result\n\n";
$res =~ s{
    <td[^>]*>
       means
    </td>
    \s*
    <td>
      (.*?)
    </td>
    }{meaning($1)}siegx;

print $json_parser->encode($results);

#########################################################

my $desc;
my $lex;


# tri helpfuncioj por sub meaning()

sub tbody {
    my ($duba,$c) = @_;
    #print "TBODY: $c\n\n";

    $c =~ s{
        <td[^>]*>
          has\s+gloss
        </td>
        \s*
        <td>
          epo:\s*(.*?)
        </td>
    }{epo_desc($1,$duba)}siegx;
    $c =~ s{
        <td[^>]*>
          lexicalization
        </td>
        \s*
        <td>
          (.*?)
        </td>
    }{lex($1,$duba)}siegx;
    return $c;
}

# NOTO: ne ĉiam enestas epo-priskribo apud la angla, ĉu rigardi ankaŭ pri alilingvaj?
sub epo_desc {
    my ($s,$duba) = @_;
    if ($s =~ m{
        <span[^>]*>
        (.*?)
        <\/span
    }x) {
        #print "DIF: $1\n";
        ## no critic (RegularExpressions::RequireExtendedFormatting)
        my $d = $1; 
        $d =~ s/<[^>]+>/ /sg;      
        ## use critic  
        $d = '?;'.$d if ($duba);
        push @$desc, $d;
    }
    return;
}

sub lex {
    my ($a,$duba) = @_;

    if ($a =~ m{
        <a\s+href="([^"]+)"> # html-referenco
        ([a-z]{3})
        :\s+
        <span[^>]*>
        ([^<]+)
        </
    }x) {
        #print "$2: $3\n";
        my $l = $lng32->{$2} || substr($2,0,2);
        my $t = ($duba? '?;'.$3 : $3);
        unless (defined $lex->{$l}) {
            $lex->{$l} = [$t];
        } else {
            push @{$lex->{$l}}, $t
        }
    }
    return;
}

sub meaning {
    my $a = shift;

    #print "A: $a\n";

    $desc = [];
    $lex = {};

    if ($a =~ m{
        <a\s+
        href="([^"]+)"
        >(.*?)
        <\/a>
    }x) {

        my $url = $1;
        my $dsc = $2; 
        my $data = get_page($1);
        ## no critic (RegularExpressions::RequireExtendedFormatting)
        $dsc =~ s/<[^>]+>/ /sg;
        ## use critic

        #print "RES: $dsc $url\n";
        #print "DATA: $data\n\n\n";

        $data =~ s{
            <tbody
            (?:[^>]+
            "display:(none)"
            )?>(.*?)
            <\/tbody>
        }{tbody($1,$2)}siegx;

        ## no critic (RegularExpressions::RequireExtendedFormatting)
        my $r = (split /;/, $url)[0]; 
        ## use critic
        $results->{$r} = {
            dsc => $dsc,
            dif => $desc,
            trd => $lex
        }
    }
    return;
}


sub get_page {
    my $page = shift;
    my $request = HTTP::Request->new(GET=>$uwn_url.$page);

    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);

    if ($response->is_success) {
        return $response->decoded_content;
    } else {
        croak $response->status_line;
    }
}
