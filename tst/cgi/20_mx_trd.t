#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);


# 1. parametroj
my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
my $url = "$REVO_HOST/cgi-bin/mx_trd.pl";

my $lng = 'de'; # germane
my $de = url_encode('kvin'); # komencu listigon tie
my $sxlosilo = 1859;

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => 'text/html');

note("Daŭros kelkajn sekundojn...\n");

$mech->post_ok($url, 
    [
        "lng" => $lng,
        "de"   => $de,
        "sxlosilo" => $sxlosilo
    ],
    "Listigu de \'$de\'"
);

note($mech->ct);
note($mech->content);

like(
    $mech->response->header('Content-Type'),
    qr{text/html;\s*charset=utf-?8}i,
    #qr{text/html}i,
    'Ĝusta enhavtipo (html, utf-8)'
);

$mech->title_like(qr/^mankantaj tradukoj/, "Titolo \'mankantaj tradukoj...\' troviĝis");
$mech->has_tag_like('body',qr/.*/, 'Troviĝas <body>...');
$mech->has_tag('h2', 'mankantaj tradukoj [de]', "Troviĝas h2[redakti]");
#
#my @input = $mech->grep_inputs({
#    type => qr/^text$/,
#    name => qr/^sercxata$/
#});
#diag explain @input;
#
#is(@input,1,"Troviĝis serĉkampo \'sercxata\'");
#
#my @submit = $mech->grep_inputs({
#    type => qr/^submit$/,
#    value => qr/^trovu$/
#});
#diag explain @submit;

#is(@submit,1,"Troviĝis serĉbutono");
#
#
#my @buttons =
#    $mech->grep_inputs({
#        type => "submit"
#    });

done_testing();
