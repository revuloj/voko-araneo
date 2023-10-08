#!/usr/bin/perl

## uzata por plenigi la datumbazon:
## 1. transformas la artikolojn art/*.xml al tez/*.json
## 2. uzas tiun ekstrakton por plenigi la tabelojn r3* de la datumbazo

use File::stat;
# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
#use Unicode::String qw(utf8);
use revodb;
use art_db; # perllib/art_db.pm

my $verbose = 1;

my $homedir = "/hp/af/ag/ri";
my $revodir = "$homedir/www/revo";
my $tezdir = "$revodir/tez";

my $xsltproc = "xsltproc $homedir/files/xsl/revo_json.xsl";

# transformu ĉiujn XML-dosierojn al JSON
my @arts;
for $xml (glob "$revodir/xml/*.xml") {
    my $json = $xml;
    $json =~ s|/xml/(.*)\.xml|/tez/$1.json|;
    push @arts, $1;

    if ( ! -e $json || stat($xml)->mtime > stat($json)->mtime) {
        print "$xml -> $json...\n" if ($verbose);
        qx($xsltproc $xml > $json);
    }
}


### uzu db_art.pm por enmeti la enhavon de JSON en la datumbazon
print "aktualigu datumbazon kap,mrk,ref el json\n" if ($verbose);

# Malfermi la datumbazon kaj plenigi la tabelojn
my $dbh = revodb::connect();
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

my $cnt = art_db::process($dbh,\@arts,$verbose);


### legu la lingvo-liston el XML kaj skribu al tabelo lng
print "aktualigu datumbazon lng el xml\n" if ($verbose);
my $ins = $dbh->prepare("INSERT INTO lng(lng_kodo,lng_nomo) VALUES (?,?)");

open IN, "< $revodir/cfg/lingvoj.xml"
    or die "ne povas malfermi dosieron lingvoj.xml";
while (<IN>) {
    if (/<lingvo kodo="([^"]+)">([^<]+)<\/lingvo>/) {
        #print "$1:$2\n";
        $ins->execute(substr($1,0,3),$2);
    }
}
close IN;

# Fermi la datumbazon
$dbh->disconnect() or die "Malkonektiĝi de DB ne funkciis.\n";

print "daŭro: ".(time - $^T)."s\nart: $cnt->{art}\nkap:$cnt->{kap}\n"
     ."mrk: $cnt->{mrk}\nref: $cnt->{ref}\ntrd: $cnt->{trd}\n" if ($verbose);	

