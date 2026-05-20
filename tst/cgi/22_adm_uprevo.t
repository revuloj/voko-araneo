#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';

# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
# pakaĵo de Debian/Ubunto: libtest-deep-perl
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

# por sencimigi Mechanize
# use LWP::ConsoleLogger::Everywhere;

my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
chomp(my $encoded_auth=`tst/cgi/22_adm_credentials.sh`);
# note($encoded_auth);

# 1. parametroj
my $url = "$REVO_HOST/cgi-bin/admin/uprevo.pl";
my $xmlurl = "$REVO_HOST/revo/xml";
my $tgzscr = "tst/cgi/22_adm_uprevo_tgz.sh";
my $art0 = 'test000.xml';
my $art = 'test333.xml';

# 2. kreu tar-arĥivon kun redakto
my $tgz;
my $tgzsh=`$tgzscr`; diag($tgzsh);

if ($tgzsh =~ m{
    (revo-\d{8}_\d{6}.tgz)
}x) {
    $tgz = $1;
} else {
    die "Mi ne trovis la nomon de tgz-arĥivo post kreo:\n".$tgzsh;
}

#diag("$xmlurl/$art0");
test_http_status("$xmlurl/$art0", 200, "$xmlurl/$art0 ekzistu (200)");
#diag("$xmlurl/$art");
test_http_status("$xmlurl/$art", 404, "$xmlurl/$art ankoraŭ ne ekzistu (404)");

# mankanta /malĝusta parametro fname
test_http_status("$url", 400, "Parametro 'fname' mankas (400)");
test_http_status("$url?fname=revo-blabla.tgz", 400, "Parametro 'fname' donas fuŝitan dosiernomon (400)");
test_http_status("$url?fname=revo-20200401_000000.tgz", 404, "Parametro 'fname' donas neekzistan dosieron (404)");

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

$mech->add_header('Authorization' => "Basic $encoded_auth");

# kapoj
$mech->add_header('Accept' => 'text/html');

# 3a. petu la paĝon kaj kontrolu la rezulton
$mech->post_ok($url, [
    kmd => 'nur_listigu',
    fname => $tgz
], "Peto al $url");

# kmd=nur_listigu devus lasi la dosierojn netuŝitaj
test_http_status("$xmlurl/$art0", 200, "$xmlurl/$art0 ekzistu (200)");
test_http_status("$xmlurl/$art", 404, "$xmlurl/$art ankoraŭ ne ekzistu (404)");

my $content = $mech->content; # malkodita enhavo

if ($content) {
    note($content);
    $mech->has_tag_like('h2',qr|/bin/tar -tvzf|,"Troviĝas /bin/tar -tvzf...");
    $mech->has_tag_like('pre',qr|revo/xml/test333.xml|,"Troviĝas revo/xml/test333.xml");
    $mech->has_tag_like('pre',qr|bv_forigu_tiujn.lst|,"Troviĝas bv_forigu_tiujn.lst");
}

# 3b. nun malpaku/forigu dosierojn
$mech->post_ok($url, [
    fname => $tgz
], "Peto al $url");

# ni atendas text/html
like(
    $mech->response->header('Content-Type'),
    qr{text/html}i,
    'Ĝusta enhavtipo (html)'
);

# 4. kontrolu la enhavon
$content = $mech->content; # malkodita enhavo

if ($content) {

    note($content);

    $mech->title_is('Sendu sxangxitajn pagxojn', 'Titolo \'Sendu...\' troviĝis');
    $mech->has_tag_like('pre',qr/$art/, "Troviĝas <pre>$art...");

    # post trakto de la arĥivo $art0 devus ne plu ekzisti, sed ja $art 
    test_http_status("$xmlurl/$art", 200, "$xmlurl/$art nun ekzistu (200)");
    test_http_status("$xmlurl/$art0", 404, "$xmlurl/$art0 ne plu ekzistu (404)");
   
} else {
    diag("Ni ne ricevis rezulton kiel HTML.");
}

done_testing();

sub test_http_status {
    my ($url,$status,$msg) = @_;
    my $statmech = WWW::Mechanize->new(autocheck => 0);
    $statmech->add_header('Authorization' => "Basic $encoded_auth");

    #diag("test: $url");
    my $res = $statmech->head($url);
    #diag("stat: ".$res->code);
    is($res->code, $status, $msg || "Peto al $url redonas $status");
}
