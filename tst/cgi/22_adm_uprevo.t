#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';

# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
# pakaĵo de Debian/Ubunto: libtest-deep-perl
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

# 1. parametroj
my $url = "http://0.0.0.0:8088/cgi-bin/admin/uprevo.pl";
my $tgzscr = "tst/cgi/22_adm_uprevo_tgz.sh";
my $art = 'test333';

# 2. kreu tar-arĥivon kun redakto
my $tgz;
my $tgzsh=`$tgzscr`;

if ($tgzsh =~ m{
    (revo-\d{8}_\d{6}.tgz)
}x) {
    $tgz = $1;
} else {
    die "Mi ne trovis la nomon de tgz-arĥivo post kreo:\n".$tgzsh;
}

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
   
} else {
    diag("Ni ne ricevis rezulton kiel HTML.");
}

done_testing();
