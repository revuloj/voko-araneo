#!/usr/bin/perl

#use File::stat;
# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
#use Unicode::String qw(utf8);
use revodb;

my $verbose = 1;

# elŝuti la liston de Viki-titoloj,elfiltri la kandidatojn por Revo-referencoj kaj eligu kiel JSON

#my $viki_url = 'http://download.wikimedia.org/eowiki/latest/eowiki-latest-all-titles-in-ns0.gz';
my $viki_local = '/hp/af/ag/ri/files/eoviki.gz';
#qx(curl -L $viki_url | gunzip > $viki_local);
          
open VIKI, "gunzip $viki_local |" 
    or die "Ne eblis malfermi $viki_local";

# PLIBONIGU:
# ni devos ankaŭ konsidero revo-fonto/cfg/viki_esc.xml
# verŝajne estus plej simple apliki ilin en la fino por
# anstataŭigi evtl. misajn fairigintajn per simpla egal-komparo

# Konektiĝi kun la datumbazo kaj malplenigi la tabelon
my $dbh = revodb::connect();
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set names utf8");

my $sth = $dbh->prepare("INSERT INTO r2_vikicelo(vik_celref, vik_artikolo) "
    ."(SELECT mrk, ? FROM r3kap WHERE kap = ? LIMIT 1) "
    ."ON DUPLICATE KEY UPDATE vik_artikolo = vik_artikolo") or die;
my $cnt;

$| = 1;

while (<VIKI>) {
    chomp;
    # print "viki-paĝo: $_\n" if ($verbose);

    # Elfiltru tiujn titolojn, kiuj ne enhavas ion krom literoj kaj strekoj,
    # la dua litero estu minusklo por eksludi mallongigojn.
    # Ni akceptas ankaŭ literojn cirilajn ktp. pro simpligo.
    # Restos tiel proksimume 2/3 de la titoloj.     
    if (/^[[:upper:]][-[:lower:]][-_[:alpha:]]*$/) {
        # print "...konvena, ni enigu\n" if ($verbose);
        print '.' if ($verbose && not $cnt % 1000);
        my $kap = $_;
        $kap =~ s/_/ /g;
        $sth->execute($_,$kap);
        $cnt++;
    }
}

close VIKI;
#unlink($viki_local);
$dbh->disconnect() or die "DB disconnect ne funkcias";

print "daŭro: ".(time - $^T)."s\nenigoj/akualigoj: $cnt\n" if ($verbose);	

