#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
use JSON;
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use Email::Valid;
use URL::Encode qw(url_encode);

#plan tests => 3; 
#no_plan;

# 1. parametroj
my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
my $url = "$REVO_HOST/cgi-bin/admin/redaktantoj-json.pl";
my $CGI_USER = $ENV{CGI_USER};
my $CGI_PWD = $ENV{CGI_PWD};
# ni kontrolos ĉu la koncerna redaktanto estas en la listo
my $redaktanto = $ENV{TEST_RETADRESO} || '_registrita_testredaktanto_@retavortaro.de';


# unless ($CGI_USER && $CGI_PWD) {
#     die "Necesas doni CGI_USER kaj CGI_PWD kiel mediovariabloj en la komandlinio";
# }

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

if ($CGI_USER && $CGI_PWD) {
    $mech->credentials($CGI_USER,$CGI_PWD);
}


# kapoj
$mech->add_header('Accept' => 'application/json');

# 3. petu la paĝon kaj kontrolu la rezulton
# get_ok() kontrolas la rezulton (stato 2xx)
$mech->post_ok($url, [], "Peto al $url");

# 4. kontrolu la enhavon
my $json_parser = JSON->new->pretty;
my $content = $mech->content; # malkodita enhavo

if ($content) {
    # ĉu la JSON estas bonorda?
    my $arrayref = eval { $json_parser->decode($content) };
    
    if (!$@ && $arrayref) {
        # Split the formatted JSON by newlines and count them
        my @lines = split /\n/, $json_parser->encode($arrayref);
        my $line_count = scalar @lines;
        
        # tio montriĝas nur kun prove -v
        note("Valida JSON ricevita, $line_count linioj.");
        # tio montriĝas ĉiam
        #diag("Valida JSON ricevita, $line_count linioj.");

        # Kontrolu la enhavon, malkomentu por sencimigo
        # note($json_parser->encode($arrayref));

        # ĉiuj eroj havas red_id, red_nomo, retadr
        cmp_deeply(
            $arrayref,
            array_each(                  
                #superhashof(
                {
                    red_id   => ignore(),
                    red_nomo => ignore(),
                    ## retadr   => array_each(re(qr{^
                    ##     [^@<>\s]+@[^@<>\s]+ # retadreso
                    ##     $}x
                    ## )), # ignore())
                    retadr   => array_each(code(sub {
                        my $email = shift;
                        return Email::Valid->address($email) ? 1 : 0;
                    }))
                }
                #)
            ),"La eroj de la redaktantolisto havas la ĝustan strukturon"
        );

        # la donita $redaktanto troviĝas en la listo
        cmp_deeply(
            $arrayref,
            superbagof(
                superhashof({
                    retadr => superbagof($redaktanto)
                }),
            ),"La respondo enhavas la retadreson \'$redaktanto\'"
        );     

    } else {
        # Se ni ne povis malkodi la enhavon. Ni avertu.
        diag("Averto: Ni ricevis ion, kio ne estas valida JSON.");
    }
} else {
    diag("Ni ne ricevis ion (JSON) pri nia serĉpeto.");
}

done_testing();


