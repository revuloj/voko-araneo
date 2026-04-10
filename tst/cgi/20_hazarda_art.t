#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

# 1. parametroj
my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
my $url = "$REVO_HOST/cgi-bin/hazarda_art.pl";

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => '*/*');

# 3. petu la kontrolpaĝon
$mech->post_ok($url, [
        "senkadroj" => 2
    ],
    'Ricevu hazardan artikolon'
);

note($mech->ct);
note($mech->content);

#$mech->content_is('text/html; charset=utf-8');
like(
    $mech->response->header('Content-Type'),
    qr{text/html;\s*charset=utf-?8}i,
    #qr{text/html}i,
    'Ĝusta enhavtipo (html, utf-8)'
);

$mech->content_like(qr/<body>/, 'Troviĝas <body>...');
$mech->has_tag_like('article',qr/.*/,'Enestas <article>');
$mech->has_tag('a','datumprotekto','Troviĝas \'datumprotekto\'');
$mech->has_tag('a','redakti...','Troviĝas \'redakti...\'');
$mech->has_tag('a','artikolversio','Troviĝas \'artikolversio\'');

done_testing();
