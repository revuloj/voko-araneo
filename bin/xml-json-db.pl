#!/usr/bin/perl

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


# transformu ciujn XML-dosierojn al JSON
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

# uzu db_art.pm por enmeti la enhavon de JSON en la datumbazon

print 'aktualigu datumbazon kap,mrk,ref el json' if ($verbose);

# Konektiĝi kun la datumbazo kaj malplenigi la tabelon
my $dbh = revodb::connect();
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

my $cnt = art_db::process($dbh,\@arts,$verbose);

$dbh->disconnect() or die "Malkonektiĝi de DB ne funkciis.\n";

print "daŭro: ".(time - $^T)."s\nart: $cnt->{art}\nkap: "
    ."$cnt->{kap}\nmrk: $cnt->{mrk}\nref: $cnt->{ref}\n" if ($verbose);	

