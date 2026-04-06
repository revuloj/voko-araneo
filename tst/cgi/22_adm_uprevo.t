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

# 1. parametroj
my $url = "http://127.0.0.1:8088/cgi-bin/admin/uprevo.pl";
my $xmlurl = "http://localhost:8088/revo/xml";
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

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => 'application/json');

# 3. petu la paĝon kaj kontrolu la rezulton
# get_ok() kontrolas la rezulton (stato 2xx)
$mech->post_ok($url, [
    fname => $tgz
], "Peto al $url");

# ni atendas text/html
like(
    $mech->response->header('Content-Type'),
    qr{text/html}i,
    'Ĝusta enhavtipo (html, utf-8)'
);

# 4. kontrolu la enhavon
my $content = $mech->content; # malkodita enhavo

if ($content) {

    diag($content);

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
    #diag("test: $url");
    my $res = $statmech->head($url);
    #diag("stat: ".$res->code);
    is($res->code, $status, $msg || "Peto al $url redonas $status");
}
