#!/usr/bin/perl

#use File::stat;
# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
#use Unicode::String qw(utf8);
use revodb;

my $verbose = 1;

my $viki_local = '/hp/af/ag/ri/files/eoviki.gz';
my $revodir = '/hp/af/ag/ri/www/revo';

# tion ni faras jam en Dockerfile por eviti ŝargon ĉe ĉiu lanĉo
#my $viki_url = 'http://download.wikimedia.org/eowiki/latest/eowiki-latest-all-titles-in-ns0.gz';
#qx(curl -L $viki_url | gunzip > $viki_local);
          
open VIKI, "gunzip -c $viki_local |" 
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
    ."ON DUPLICATE KEY UPDATE vik_artikolo = vik_artikolo");
my $sthe = $dbh->prepare("INSERT INTO r2_vikicelo(vik_celref, vik_artikolo) "
    ."VALUES (?,?) ON DUPLICATE KEY UPDATE vik_artikolo = vik_artikolo");
my $sthd = $dbh->prepare("DELETE FROM r2_vikicelo WHERE vik_celref = ? ");   

my $cnt;

$| = 1;

while (<VIKI>) {
    chomp;
    #print "viki-paĝo: $_\n" if ($verbose);

    # Elfiltru tiujn titolojn, kiuj ne enhavas ion krom literoj kaj strekoj,
    # la dua litero estu minusklo por eksludi mallongigojn.
    # Ni akceptas ankaŭ literojn cirilajn ktp. pro simpligo.
    # Restos tiel proksimume 2/3 de la titoloj.     
    if (/^[[:upper:]][-[:lower:]][-_[:alpha:]]*$/) {
     #print "...konvena kandidato, ni provu enigi\n" if ($verbose);
        print '.' if ($verbose && not $cnt % 1000);
        my $kap = $_;
        $kap =~ s/_/ /g;
        $sth->execute($_,$kap);
        $cnt++;
    }
}

close VIKI;

# nun ni ankoraŭ apliku esceptojn, ni faras tion post la precipa ŝargo, ĉar la esceptoj eventuale anstataŭigu 
# <vikiref>
# <r v="" r="tag.0a"/>
# <r v="Niels_Henrik_Abel" r="abel1"/>
my $esc;

open XML, "< $revodir/cfg/vikiref_esc.xml"
    or die "ne povas malfermi dosieron vikiref_esc.xml";
while (<XML>) {
    if (/<r\s+v\s*=\s*"([^"]+)"\s+r\s*=\s*"([^"]+)"\s*\/>/) {
        #print "$1:$2\n";
        if ($1) {
            # aldonu aŭ aktualigu escepton
            $sthe->execute($2,$1);
        } else {
            # v="" - ni ne volas referenci al Viki-paĝo, do forigu la referencon
            $sthd->execute($2);
        };
        $esc++;
    }
}
close XML;

# kiom da referencoj nun estas en la tabelo?
my $c = $dbh->selectrow_hashref("SELECT count(*) AS c FROM r2_vikicelo");
my $rec_cnt = $c->{c};

#unlink($viki_local);
$dbh->disconnect() or die "DB disconnect ne funkcias";

print "daŭro: ".(time - $^T)."s\nkandidatoj: $cnt, esceptoj: $esc, referencoj: $rec_cnt\n" if ($verbose);	

