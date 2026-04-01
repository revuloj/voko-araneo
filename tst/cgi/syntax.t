#!/usr/bin/perl

use strict; use warnings;
use utf8; use open ':std', ':encoding(UTF-8)';
use Test::More; 

#use lib('./cgi');
my $LIB ='./cgi/perllib';
my $eldono = '2p';

sub sintaks_kontrolo {
    my $cgi = shift;

    my $eligo = `perl -I$LIB -c $cgi 2>&1`;
    ok($? == 0, "Sintakskontrolo: $cgi") or diag($eligo);
}

# por kontroli (kaj korekti) sintakson de unuopa 
# oni povas uzi 
# perl -I./cgi/perllib -c cgi/<skripto...>.pl

sintaks_kontrolo("./cgi/hazarda_art.pl");
sintaks_kontrolo("./cgi/mrk_eraroj.pl");
sintaks_kontrolo("./cgi/mx_trd.pl");
sintaks_kontrolo("./cgi/nombroj.pl");
sintaks_kontrolo("./cgi/sercxu-json-$eldono.pl");
sintaks_kontrolo("./cgi/sercxu.pl");
sintaks_kontrolo("./cgi/sercxu-vivo.pl");
sintaks_kontrolo("./cgi/traduku-uwn.pl");
sintaks_kontrolo("./cgi/traduku-wiki.pl");
sintaks_kontrolo("./cgi/vokohtmlx.pl");

sintaks_kontrolo("./cgi/vokomail.pl");
sintaks_kontrolo("./cgi/vokomailx.pl");
sintaks_kontrolo("./cgi/vokoref-json.pl");
sintaks_kontrolo("./cgi/vokosubm-json.pl");
sintaks_kontrolo("./cgi/vokosubmx.pl");

sintaks_kontrolo("./cgi/admin/art_db.pl");
sintaks_kontrolo("./cgi/admin/checkencode.pl");
sintaks_kontrolo("./cgi/admin/checkversioj.pl");
sintaks_kontrolo("./cgi/admin/dbtest.pl");
sintaks_kontrolo("./cgi/admin/perltest.pl");
sintaks_kontrolo("./cgi/admin/redaktantoj-json.pl");
sintaks_kontrolo("./cgi/admin/redaktantoj.pl");
sintaks_kontrolo("./cgi/admin/resendu.pl");
sintaks_kontrolo("./cgi/admin/submeto.pl");
sintaks_kontrolo("./cgi/admin/time.pl");
sintaks_kontrolo("./cgi/admin/upofc.pl");
sintaks_kontrolo("./cgi/admin/uprevo.pl");
sintaks_kontrolo("./cgi/admin/uprevorm.pl");
sintaks_kontrolo("./cgi/admin/uprevotv.pl");
sintaks_kontrolo("./cgi/admin/upviki.pl");

done_testing();
