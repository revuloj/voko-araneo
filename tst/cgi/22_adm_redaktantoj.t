#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

#plan tests => 3; 
#no_plan;

# 1. parametroj
my $url = "http://0.0.0.0:8088/cgi-bin/admin/redaktantoj.pl";
my $CGI_USER = $ENV{CGI_USER};
my $CGI_PWD = $ENV{CGI_PWD};
# ni kontrolos ĉu la koncerna redaktanto estas en la listo
my $redaktanto = $ENV{TEST_RETADRESO} || '_registrita_testredaktanto_@retavortaro.de';


unless ($CGI_USER && $CGI_PWD) {
    die "Necesas doni CGI_USER kaj CGI_PWD kiel mediovariabloj en la komandlinio";
}

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();
$mech->credentials($CGI_USER,$CGI_PWD);

# kapoj
$mech->add_header('Accept' => 'application/json');

# 3. petu la paĝon kaj kontrolu la rezulton
# get_ok() kontrolas la rezulton (stato 2xx)
$mech->post_ok($url, [], "Peto al $url");

# 4. kontrolu la enhavon
my $content = $mech->content; # malkodita enhavo

if ($content) {
    # Kontrolu la enhavon
    note($content);

    my @lines = split(/\n/,$content);

    # ĉiuj eroj havas red_nomo, retadr
    cmp_deeply(
        \@lines,
        array_each( 
            re(qr{^
                (?:[A-za-z\-\'\.]{1,30}\s+){2,7} # nomo askie
                (?:<[^@<>\s]+@[^@<>\s]+>\s*){1,10} # retadreso(j)
                $}x
            )
        ),"La eroj de la redaktantolisto havas la ĝustan strukturon"
    );

    cmp_deeply(
        \@lines,
        code(sub {
            my $lines = shift;
            return scalar grep { index($_, $redaktanto) != -1 } @$lines;
        }),"La respondo enhavas la retadreson \'$redaktanto\'"
    );

} else {
    diag("Ni ne ricevis ion pri nia serĉpeto.");
}

done_testing();


