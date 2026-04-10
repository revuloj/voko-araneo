#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
use JSON;
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
my $eldono = '2p';

# 1. parametroj
my $sercxata = url_encode('sen%');
my $lingvoj = 'en,de,fr,nl';
my $url = "$REVO_HOST/cgi-bin/sercxu-json-$eldono.pl";

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => 'application/json');
$mech->add_header('Accept-Language' => $lingvoj);

# 3. petu la paĝon kaj kontrolu la rezulton
# get_ok() kontrolas la rezulton (stato 2xx)
$mech->post_ok($url, [
    sxlosilo => 1887,
    sercxata => $sercxata
], "Peto al $url");

# 4. kontrolu la enhavon
my $json_parser = JSON->new->pretty;
my $content = $mech->content; # malkodita enhavo

if ($content) {
    # ĉu la JSON estas bonorda?
    my $hashref = eval { $json_parser->decode($content) };
    

    if (!$@ && $hashref) {
        # Split the formatted JSON by newlines and count them
        my @lines = split /\n/, $json_parser->encode($hashref);
        my $line_count = scalar @lines;
        
        # tio montriĝas nur kun prove -v
        note("Valida JSON ricevita, $line_count linioj.");
        # tio montriĝas ĉiam
        #diag("Valida JSON ricevita, $line_count linioj.");

        # Kontrolu la enhavon
        note($json_parser->encode($hashref));

        # ni ricevis rezultojn po eo kaj la serĉlingvoj
        ok(exists $hashref->{eo}, "Respondo enhavas 'eo'");
        ok(exists $hashref->{trd}, "Respondo enhavas 'trd'");
        #for my $lng (split(',',$lingvoj)) {
        #    ok(exists $hashref->{$lng}, "Respondo enhavas '$lng'");
        #}

        # ĉu enestas eo:sen, de:ohne?
        # iom riska, se tio ne estas la unua ero, la testo fiaskos:
        ### is_deeply($hashref->{"eo"}->[0], ["sen.0","sen","de","ohne",""], "Respondo enhavas eo:sen, de:ohne");
        # do pli bone do traserĉu la tutan eo-liston tiel:
        cmp_deeply(
            $hashref->{eo},
            array_each(
                any(["sen.0", "sen", "de", "ohne", ""])
            ),
            "La respondo enhavas eo:sen, de:ohne"
        );
        cmp_deeply(
            $hashref->{eo},
            array_each(
                any(["sen.0", "sen", "en", "without", ""]) 
            ),
            "La respondo enhavas 'sen' kun angla traduko 'without"
        );
        cmp_deeply(
            $hashref->{eo},
            array_each(
                any(["sen.0", "sen", "fr", "sans", ""]) 
            ),
            "La respondo enhavas 'sen' kun franca traduko 'sans"
        );

    } else {
        # Se ni ne povis malkodi la enhavon. Ni avertu.
        diag("Averto: Ni ricevis ion, kio ne estas valida JSON.");
    }
} else {
    diag("Ni ne ricevis ion (JSON) pri nia serĉpeto.");
}

done_testing();
