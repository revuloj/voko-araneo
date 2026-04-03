#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
use JSON;
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

#plan tests => 3; 
#no_plan;

# 1. parametroj
my $url = "http://0.0.0.0:8088/cgi-bin/vokosubm-json.pl";
my $url_submeto = "http://0.0.0.0:8088/cgi-bin/vokosubmx.pl";
my $redaktanto = $ENV{TEST_RETADRESO} || '_registrita_testredaktanto_@retavortaro.de';

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# unue submetu artikolon, kion ni poste ricevu en la listo
test_submeto();

# kapoj
$mech->add_header('Accept' => 'application/json');

# 3. petu la paĝon kaj kontrolu la rezulton
# get_ok() kontrolas la rezulton (stato 2xx)
$mech->post_ok($url, [
    email => $redaktanto
], "Peto al $url");

# 4. kontrolu la enhavon
my $json_parser = JSON->new->pretty;
my $content = $mech->content; # malkodita enhavo

if ($content) {
    # ĉu la JSON estas bonorda?
    my $arrayref = eval { $json_parser->decode($content) };
    
    if (!$@ && $arrayref) {
        # Split the formatted JSON by newlines and count them
        my @lines = split /\n/, $json_parser->encode($arrayref);
        my $line_count = scalar @lines;
        
        # tio montriĝas nur kun prove -v
        note("Valida JSON ricevita, $line_count linioj.");
        # tio montriĝas ĉiam
        #diag("Valida JSON ricevita, $line_count linioj.");

        # Kontrolu la enhavon
        note($json_parser->encode($arrayref));

        cmp_deeply(
            $arrayref,
            superbagof({
                "state" => "nov", 
                "fname" => "test", 
                "result" => undef, 
                "id" => ignore(), 
                "time" => ignore(), 
                "desc" => "nur testo"
            }),
            "La respondo enhavas la novan submeton \'nur testo\'"
        );

    } else {
        # Se ni ne povis malkodi la enhavon. Ni avertu.
        diag("Averto: Ni ricevis ion, kio ne estas valida JSON.");
    }
} else {
    diag("Ni ne ricevis ion (JSON) pri nia serĉpeto.");
}

done_testing();


sub test_submeto {

    my $xml = << '~~~~~';
<?xml version="1.0"?><!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd"><vortaro>
<art mrk="\$Id: kvin.xml,v 1.116 2021/06/22 19:02:35 revo Exp \$">
<kap><ofc>*</ofc><rad>kvin</rad></kap>
<drv mrk="kvin.0"><kap><tld/></kap>
<snc><dif>Kvar kaj unu. Matematika simbolo 5:<ekz><tld/> kaj sep faras dek du
<fnt><bib>F</bib><lok>&FE; 12</lok></fnt>;</ekz>
</dif><ref tip="lst" cel="nombr.0o.MAT" lst="voko:nombroj" val="5">nombro</ref>
</snc></drv></art></vortaro>
~~~~~

    $mech->post_ok($url_submeto, 
        [
            art   => 'test',
            redaktanto  => $redaktanto,
            sxangxo  => 'nur testo', 
            nova => 0,
            command => 'forsendo',
            xmlTxt => $xml
        ],
        'Subemtu artikolon prepare al la plia testo ricevi submetoliston...'
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

