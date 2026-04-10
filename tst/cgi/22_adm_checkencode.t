#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';

# pakaĵo de Debian/Ubunto: libwww-mechanize-perl libtest-www-mechanize-perl
use WWW::Mechanize; use Test::WWW::Mechanize;
# pakaĵo de Debian/Ubunto: libtest-deep-perl
use Test::More; #use Test::Deep;
use URL::Encode qw(url_encode);

# por sencimigi Mechanize
# use LWP::ConsoleLogger::Everywhere;

my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';

# 1. parametroj
my $url = "$REVO_HOST/cgi-bin/admin/checkencode.pl";
my $xmlurl = "$REVO_HOST/revo/xml";
my $xmlscr = "tst/cgi/22_adm_checkencode_xml.sh";
my $art = 'testccc.xml';

# 2. sendu artikolon por testi al Araneujo
my $xmlsh=`script -q -c \"$xmlscr\" /dev/null 2>&1`;

my $xml;
if ($xmlsh =~ m{
    (testccc)\.xml
}x) {
    $xml = $1;
} else {
    warn($xmlsh);
    die "Mi ne trovis la nomon de XML-artikolo post kreo:\n".$xmlsh;
}

#diag("$xmlurl/$art");
test_http_status("$xmlurl/$art", 200, "$xmlurl/$art ekzistu (200)");

# mankanta /malĝusta parametro fname
#test_http_status("$url", 400, "Parametro 'fname' mankas (400)");

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => 'text/html');

# 3a. petu la paĝon kaj kontrolu la rezulton
$mech->post_ok($url, [
    art => $xml
], "Peto al $url");

# ni atendas text/html
like(
    $mech->response->header('Content-Type'),
    qr{text/html}i,
    'Ĝusta enhavtipo (html)'
);

my $content = $mech->content; # malkodita enhavo

if ($content) {
    note($content);
    $mech->has_tag_like('h1',qr|Enhavo de $xml.xml|,"Troviĝas titolo 'Enhavo de $xml.xml'");

    like($content, qr/<h1>Fino/, 'Ni atendas titolon Fino');
    unlike($content, qr/<pre>/, 'Ni atendas neniun <pre> kun iuj diferencoj');

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
