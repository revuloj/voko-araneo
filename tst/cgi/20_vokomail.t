#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);


# 1. parametroj
my $url = "http://0.0.0.0:8088/cgi-bin/vokomail.pl";
my $art = 'kvin';

# transdonu registrita test-redaktanton en medivariablo,
# alie la testo fiaskos pro rifuzo de la redakto
my $redaktanto = $ENV{TEST_RETADRESO} || '_registrita_testredaktanto_@retavortaro.de';
my $spamanto = '_neregistrita_redaktanto_@retavortaro.de';

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => '*/*');


$mech->post_ok($url, 
    [
        "art"   => $art,
        "redaktanto"  => $redaktanto
    ],
    "Ricevu redaktoformularon por \'$art\'"
);

note($mech->ct);
note($mech->content);

like(
    $mech->response->header('Content-Type'),
    qr{text/html;\s*charset=utf-?8}i,
    #qr{text/html}i,
    'Ĝusta enhavtipo (html, utf-8)'
);

$mech->title_is('redakti kvin', 'Titolo \'redakti kvin\' troviĝis');
$mech->has_tag_like('body',qr/.*/, 'Troviĝas <body>...');
$mech->has_tag_like('textarea',qr/\$Id: kvin\.xml,v/, 'Troviĝas tekstarea kun la artikolo kvin.xml...');

# $mech->button_exists_ok('antaŭrigardu','Troviĝas butono \'antaŭrigardu\'');
# $mech->button_exists_ok('konservu','Troviĝas butono \'konservu\'');
# $mech->button_exists_ok('kreu','Troviĝas butono \'kreu\'');

my @buttons =
    $mech->grep_inputs({
        type => "submit"
    });

diag explain @buttons;

# vd. 22_adm_redaktantoj-json.t ?
cmp_deeply(
    \@buttons,
    superbagof(
        superhashof({
            value => 'konservu'
        }),    
    ),
    "Troviĝas butono \'konservu\'"
);    

done_testing();
