#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);


# 1. parametroj
my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
my $url = "$REVO_HOST/cgi-bin/vokosubmx.pl";

# transdonu registrita test-redaktanton en medivariablo,
# alie la testo fiaskos pro rifuzo de la redakto
my $redaktanto = $ENV{TEST_RETADRESO} || '_registrita_testredaktanto_@retavortaro.de';
my $spamanto = '_neregistrita_redaktanto_@retavortaro.de';

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => '*/*');

my $xmlTxt = << '~~~~~';
<?xml version="1.0"?><!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd"><vortaro>
<art mrk="\$Id: kvin.xml,v 1.116 2021/06/22 19:02:35 revo Exp \$">
<kap><ofc>*</ofc><rad>kvin</rad></kap>
<drv mrk="kvin.0"><kap><tld/></kap>
<snc><dif>Kvar kaj unu. Matematika simbolo 5:<ekz><tld/> kaj sep faras dek du
<fnt><bib>F</bib><lok>&FE; 12</lok></fnt>;</ekz>
</dif><ref tip="lst" cel="nombr.0o.MAT" lst="voko:nombroj" val="5">nombro</ref>
</snc></drv></art></vortaro>
~~~~~


note($xmlTxt);

# kontrolo de bona XML devus doni neniujn erarojn
nur_kontrolo($xmlTxt,'Kontrolu bonordan artikolon \'kvin\'');
# aldonaj testoj pri la enhavo
$mech->scraped_id_like('xml_err', qr/^\s*$/,'Neniuj sintaks-eraroj');
$mech->scraped_id_like('ref_err', qr/^\s*$/,'Neniuj ref-eraroj'); 

# redakto de spamanto rifuziĝu
spamanto($xmlTxt,'Sendaĵo de spamanto rifuziĝu');

forsendo($xmlTxt,'Provu frosendi artikolon \'kvin\'');
# $mech->scraped_id_like('malkonfirmo', qr/problemo kun la retpoŝta servo/,'Send-eraro');
$mech->scraped_id_like('konfirmo', qr/Bone/,'Konfirmo de submeto');

# kontrolo de malbona XML devus doni koncernajn erarojn
$xmlTxt =~ s/<rad>//;
$xmlTxt =~ s/cel="nombr.0o.MAT"/cel="noXmbr.MAT"/;
note($xmlTxt);

nur_kontrolo($xmlTxt,'Kontrolu malbonan artikolon \'kvin\'');
$mech->scraped_id_like('xml_err', qr/^\s*Eraro:\s+Malkongrua elementofino.*kap.*pozicio 3:27\s*$/,'Sintaks-eraro');
$mech->scraped_id_like('ref_err', qr/Referenco celas al marko "noXmbr.MAT", kiu ne ekzistas\./,'Referenc-eraro');

done_testing();

# 3. petu la kontrolpaĝon

sub nur_kontrolo {
    my ($xml,$testo) = @_;

    $mech->post_ok($url, 
        [
            art   => 'test',
            redaktanto  => $redaktanto,
            sxangxo  => 'nur testo', 
            nova => 0,
            command => 'nur_kontrolo',
            xmlTxt => $xml
        ],
        $testo
    );

    note($mech->ct);
    note($mech->content);

    #$mech->content_is('text/html; charset=utf-8');
    like(
        $mech->response->header('Content-Type'),
        qr{text/html;\s*charset=utf-?8}i,
        'Ĝusta enhavtipo (html, utf-8)'
    );

    $mech->title_is('vokosubmx', 'Titolo \'vokosubmx\' troviĝis');
    $mech->content_like(qr/<body>/, 'body...');
    $mech->id_exists_ok('xml_err','Troviĝas alineo \'xml_err\'');
    $mech->id_exists_ok('ref_err','Troviĝas alineo \'ref_err\'');
}


sub forsendo {
    my ($xml,$testo) = @_;

    $mech->post_ok($url, 
        [
            art   => 'test',
            redaktanto  => $redaktanto,
            sxangxo  => 'nur testo', 
            nova => 0,
            command => 'forsendo',
            xmlTxt => $xml
        ],
        $testo
    );

    note($mech->ct);
    note($mech->content);

    #$mech->content_is('text/html; charset=utf-8');
    like(
        $mech->response->header('Content-Type'),
        qr{text/html;\s*charset=utf-?8}i,
        'Ĝusta enhavtipo (html, utf-8)'
    );

    $mech->title_is('vokosubmx', 'Titolo \'vokosubmx\' troviĝis');
    $mech->content_like(qr/<body>/, 'body...');
    $mech->content_like(qr/ni ne povas sendi al vi kopion/,'ne eblis sendi kopion');
    $mech->id_exists_ok('xml_err','Troviĝas alineo \'xml_err\'');
    $mech->id_exists_ok('ref_err','Troviĝas alineo \'ref_err\'');
}



sub spamanto {
    my ($xml,$testo) = @_;

    $mech->post_ok($url, 
        [
            art   => 'test',
            redaktanto  => $spamanto,
            sxangxo  => 'nur testo', 
            nova => 0,
            command => 'nur_kontrolo',
            xmlTxt => $xml
        ],
        $testo
    );

    note($mech->ct);
    note($mech->content);

    #$mech->content_is('text/html; charset=utf-8');
    like(
        $mech->response->header('Content-Type'),
        qr{text/html;\s*charset=utf-?8}i,
        'Ĝusta enhavtipo (html, utf-8)'
    );

    $mech->title_is('vokosubmx', 'Titolo \'vokosubmx\' troviĝis');
    $mech->content_like(qr/<body>/, 'body...');
    $mech->id_exists_ok('red_err','Troviĝas alineo \'red_err\'');
    $mech->scraped_id_like('red_err', qr/ne estas registrita kiel redaktanto/,'Enestu rifuzo'); 
}



