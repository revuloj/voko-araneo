#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use Email::Valid;
use URL::Encode qw(url_encode);

#plan tests => 3; 
#no_plan;

# 1. parametroj
my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
my $url = "$REVO_HOST/cgi-bin/admin/redaktantoj.pl";

# ni kontrolos ĉu la koncerna redaktanto estas en la listo
my $redaktanto = $ENV{TEST_RETADRESO} || '_registrita_testredaktanto_@retavortaro.de';

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

chomp(my $encoded_auth=`tst/cgi/22_adm_credentials.sh`);
# note($encoded_auth);
$mech->add_header('Authorization' => "Basic $encoded_auth");

# kapoj
$mech->add_header('Accept' => 'application/json');

# 3. petu la paĝon kaj kontrolu la rezulton
# get_ok() kontrolas la rezulton (stato 2xx)
$mech->post_ok($url, [], "Peto al $url");

# 4. kontrolu la enhavon
my $content = $mech->content; # malkodita enhavo

if ($content) {
    # Kontrolu la enhavon, malkomentu por sencimigo
    # note($content);

    my @lines = split(/\n/,$content);

    # ĉiuj eroj havas red_nomo, retadr
    ## cmp_deeply(
    ##     \@lines,
    ##     array_each( 
    ##         re(qr{^
    ##             (?:[A-za-z\-\'\.]{1,30}\s+){2,7} # nomo askie
    ##             (?:<[^@<>\s]+@[^@<>\s]+>\s*){1,10} # retadreso(j)
    ##             $}x
    ##         )
    ##     ),"La eroj de la redaktantolisto havas la ĝustan strukturon"
    ## );

    cmp_deeply(
        \@lines,
        array_each(
            code(sub {
                my $line = shift;
                my ($nomo,@retadr) = 
                    $line =~ qr{^
                        ([^<]+) # nomo
                        (?:<([^<>]+)>\s*){1,10} # retadreso(j)
                        $}x;
                my $valid = ($nomo =~ /(?:[A-za-z\-\'\.]{1,30}\s+){2,7}/x)? 1 : 0;
                unless ($valid) {
                    diag "Nevalida nomo: $nomo\n";
                }
                for (@retadr) {
                    $valid *= (Email::Valid->address($_))? 1 : 0;
                    unless ($valid) {
                        diag "Nevalida retadreso: $_\n";
                    }
                };
                return $valid;
            })
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


