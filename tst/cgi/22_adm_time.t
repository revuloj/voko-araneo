#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';

# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
# pakaĵo de Debian/Ubunto: libtest-deep-perl
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

# 1. parametroj
my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
my $url = "$REVO_HOST/cgi-bin/admin/time.pl";

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => 'application/json');

chomp(my $encoded_auth=`tst/cgi/22_adm_credentials.sh`);
# note($encoded_auth);
$mech->add_header('Authorization' => "Basic $encoded_auth");


# 3. petu la paĝon kaj kontrolu la rezulton
# get_ok() kontrolas la rezulton (stato 2xx)
$mech->post_ok($url, [], "Peto al $url");

# ni atendas text/html
like(
    $mech->response->header('Content-Type'),
    qr{text/html}i,
    'Ĝusta enhavtipo (html, utf-8)'
);

# 4. kontrolu la enhavon
my $content = $mech->content; # malkodita enhavo

if ($content) {

    $mech->title_is('Servila tempo', 'Titolo \'Servila tempo\' troviĝis');
    $mech->has_tag_like('h1',qr/^timestamp=/, "Troviĝas timestamp=...");
#    $mech->has_tag_like('pre',qr/art: 1\s+kap: 1\s+mrk: 4\s+ref: 3\s+trd: 45/,'Analizrezulto troviĝis');   
   
} else {
    diag("Ni ne ricevis rezulton kiel HTML.");
}

done_testing();
