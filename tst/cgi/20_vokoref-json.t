#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
use JSON;
# pakaĵo de Debian/Ubunto: libtest-www-mechanize-perl
use Test::WWW::Mechanize;
use Test::More; use Test::Deep;
use URL::Encode qw(url_encode);

# 1. parametroj
my $url = "http://0.0.0.0:8088/cgi-bin/vokoref-json.pl";
my $art = 'oktav';

# 2. preparo de TTT-testkliento
my $mech = Test::WWW::Mechanize->new();

# kapoj
$mech->add_header('Accept' => 'application/json');

# 3. petu la paĝon kaj kontrolu la rezulton
# get_ok() kontrolas la rezulton (stato 2xx)
$mech->post_ok($url, [
    art => $art
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
        ok(exists $hashref->{tez}, "Respondo enhavas 'tez'");
        ok(exists $hashref->{ofc}, "Respondo enhavas 'ofc'");
        ok(exists $hashref->{viki}, "Respondo enhavas 'viki'");

        # ni devus unue plenumi admin/upofc.pl por ricevi tiujn
        cmp_deeply(
            $hashref->{ofc},
            superbagof({
                "f" => "oa",
                "s" => "OA2,III",
                "m" => "oktav.0o",
                "r" => ignore()
            }),
            "La respondo enhavas referencon al OA2,III"
        );
        cmp_deeply(
            $hashref->{viki},
            superbagof({
                "v" => "Oktavo",
                "m" => "oktav.0o"
            }),
            "La respondo enhavas Viki-referencon al Oktavo"
        );
        cmp_deeply(
            $hashref->{tez},
            superbagof(
            {
                "mrk" => "oktav.0o.MUZ",
                "tip" => "sin",
                "cel" => {
                   "k" => "okto",
                   "m" => "okt.0o"
                }
            },
            {
                "mrk" => "oktav.0o.TIP",
                "tip" => "super",
                "cel" => {
                    "m" => "kajer.0o",
                    "k" => "kajero"
                }
            },               
            {
                "mrk" => "oktav.0o.KRI",
                "tip" => "super",
                "cel" => {
                    "m" => "tag.0o.dato",
                    "k" => "tago",
                    "n" => "3"
                } 
            }),
            "La respondo enhavas referencon al sinonimo 'okto' kaj supernocioj kajero (TIP), dato (KRI)"
        );

    } else {
        # Se ni ne povis malkodi la enhavon. Ni avertu.
        diag("Averto: Ni ricevis ion, kio ne estas valida JSON.");
    }
} else {
    diag("Ni ne ricevis ion (JSON) pri nia serĉpeto.");
}

done_testing();
