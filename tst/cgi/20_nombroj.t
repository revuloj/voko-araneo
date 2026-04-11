#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
use JSON;
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

# 1. parametroj
my $REVO_HOST = $ENV{REVO_HOST} || 'http://127.0.0.1:8088';
my $url = "$REVO_HOST/cgi-bin/nombroj.pl";

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

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
        ok(exists $hashref->{kap}, "Respondo enhavas 'kap'");
        ok(exists $hashref->{trd}, "Respondo enhavas 'trd'");

        note("Se la sekvaj testoj fiaskas, eble la datumbazo ankoraŭ pleniĝas post ĵusa lanĉo!");
        ok($hashref->{kap}->[0] > 35000, "La datumbazo enhavas almenaŭ 35000 kapvortojn");
        ok($hashref->{trd}->[0] > 800000, "La datumbazo enhavas almenaŭ 80000 tradukojn");

    } else {
        # Se ni ne povis malkodi la enhavon. Ni avertu.
        diag("Averto: Ni ricevis ion, kio ne estas valida JSON.");
    }
} else {
    diag("Ni ne ricevis ion (JSON) pri nia serĉpeto.");
}

done_testing();
