#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

# 1. parametroj
my $url = "http://0.0.0.0:8088/cgi-bin/vokohtmlx.pl";

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

# 3. petu la kontrolpaĝon
$mech->post_ok($url, 
    [
        xmlTxt => $xmlTxt
    ],
    'Ricevu antaŭrigardon de artikolo'
);

note($mech->ct);
note($mech->content);

#$mech->content_is('text/html; charset=utf-8');
like(
    $mech->response->header('Content-Type'),
    qr{text/html;\s*charset=utf-?8}i,
    'Ĝusta enhavtipo (html, utf-8)'
);

$mech->title_is('kvin', 'Titolo \'kvin\' troviĝis');
$mech->content_like(qr/<body>/, 'Troviĝas <body>...');
$mech->id_exists_ok('kvin.0','Troviĝas \'kvin.0\'');
$mech->id_exists_ok('ekz_1','Troviĝas \'ekz_1\'');
$mech->has_tag('a','datumprotekto','Troviĝas \'datumprotekto\'');
$mech->has_tag('a','redakti...','Troviĝas \'redakti...\'');
$mech->has_tag('a','artikolversio','Troviĝas \'artikolversio\'');

done_testing();
